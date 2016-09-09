//
//  GroupDetailViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import CoreData

class GroupDetailViewController: UITableViewController, NSFetchedResultsControllerDelegate, AddUserControllerDelegate {

	var managedObjectContext: NSManagedObjectContext? = nil
	var detailItem: Group? {
		didSet {
			// Update the view.
			self.configureView()
		}
	}

	@IBAction func showHistory(sender: AnyObject) {
		self.performSegueWithIdentifier("showHistory", sender: nil);
	}


	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			self.clearsSelectionOnViewWillAppear = false
			self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(GroupDetailViewController.insertNewObject(_:)))
		self.navigationItem.rightBarButtonItem = addButton
	}

	func configureView() {
        self.title = self.detailItem!.name
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(sender: AnyObject) {
		self.performSegueWithIdentifier("addMember", sender: nil)
	}

	func addMemberToGroup(newMember: Member) {
		self.dismissViewControllerAnimated(true, completion: nil)

		// If appropriate, configure the new managed object.
		if let group = detailItem {
			if !group.members.containsObject(newMember) {
				group.addMember(newMember)
			}
			else {
				//TODO: inform user about not adding an existing member
				//abort()
				let alertcontroller = UIAlertController(title: "Error", message: "User already exists in group", preferredStyle: .Alert)
				alertcontroller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
				self.presentViewController(alertcontroller, animated: true, completion: nil)
				return
			}
		}

		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		delegate.saveContext()
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Group
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				controller.detailItem = object
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
		if segue.identifier == "addMember" {
			let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AddUserTableViewController
			controller.managedObjectContext = self.managedObjectContext
			controller.delegate = self
		}
		if segue.identifier == "showHistory" {
			let controller = segue.destinationViewController as! PaymentsHistoryViewController
			controller.managedObjectContext = self.managedObjectContext
			controller.detailItem = self.detailItem
		}
	}

	func incrementPaymentCountForIndexPath(indexPath : NSIndexPath) {
		if let object = self.detailItem?.getMembers()[indexPath.row] {
			let context = self.fetchedResultsController.managedObjectContext
			let newEvent = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: context) as! Event
			newEvent.member = object
			newEvent.timeStamp = NSDate()
			self.detailItem!.addPayment(newEvent)
			// Save the context.
			let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
			delegate.saveContext()
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
//		return self.fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
//		return sectionInfo.numberOfObjects
		return self.detailItem?.getNumberOfMembers() ?? 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		self.configureCell(cell, atIndexPath: indexPath)
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false//true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			let context = self.fetchedResultsController.managedObjectContext
			context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)

			let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
			delegate.saveContext()
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.incrementPaymentCountForIndexPath(indexPath)
		self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.tableView.reloadData()
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		let object = self.detailItem?.getMembers()[indexPath.row] as Member!
		cell.textLabel!.text = object.name
		if let payments = self.detailItem?.getPayments() {
			var paymentsCount = 0
			for pEvent in payments {
				if pEvent.member == object {
					paymentsCount += 1
				}
			}
			cell.detailTextLabel!.text = "\(paymentsCount)"
		}

	}

	// MARK: - Fetched results controller

	var fetchedResultsController: NSFetchedResultsController {
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}

		let fetchRequest = NSFetchRequest()
		// Edit the entity name as appropriate.
		let entity = NSEntityDescription.entityForName("Member", inManagedObjectContext: self.managedObjectContext!)
		fetchRequest.entity = entity

		// Set the batch size to a suitable number.
		fetchRequest.fetchBatchSize = 20

		// Edit the sort key as appropriate.
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)

		fetchRequest.sortDescriptors = [sortDescriptor]

		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
		aFetchedResultsController.delegate = self
		_fetchedResultsController = aFetchedResultsController

		do {
			try _fetchedResultsController!.performFetch()
		} catch _ as NSError {
			abort()
		}

		return _fetchedResultsController!
	}
	var _fetchedResultsController: NSFetchedResultsController? = nil

	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		switch type {
		case .Insert:
			self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
		case .Delete:
			self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
		default:
			return
		}
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		switch type {
		case .Insert:
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
			break
		case .Delete:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
			break
		case .Update:
			self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
			break
		case .Move:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
			break
		}
	}

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		self.tableView.endUpdates()
	}

	/*
	// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
	// In the simplest, most efficient, case, reload the table view.
	self.tableView.reloadData()
	}
	*/
}

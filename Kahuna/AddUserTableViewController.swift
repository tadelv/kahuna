//
//  AddUserTableViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import CoreData

protocol AddUserControllerDelegate {
	func addMemberToGroup(newMember: Member)
}

class AddUserTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var managedObjectContext: NSManagedObjectContext? = nil
	var delegate: AddUserControllerDelegate? = nil


	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			self.clearsSelectionOnViewWillAppear = false
			self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(AddUserTableViewController.dismiss(_:)))
		self.navigationItem.leftBarButtonItem = cancelButtonItem

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(AddUserTableViewController.insertNewObject(_:)))
		self.navigationItem.rightBarButtonItem = addButton
	}

	func configureView() {

	}

	func dismiss(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(sender: AnyObject) {
		let alertController = UIAlertController(title: "New", message: "", preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addTextFieldWithConfigurationHandler {(textField: UITextField!) in
			textField.placeholder = "Group member"
		}
		alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
			let textField = alertController.textFields?.first as UITextField!
			self.insertMemberWithName(textField.text)
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
		}))
		self.presentViewController(alertController, animated: true) { () -> Void in
		}
	}

	func insertMemberWithName(newName: String!) {
		//TODO: check uniqueness
		let context = self.fetchedResultsController.managedObjectContext
		let entity = self.fetchedResultsController.fetchRequest.entity!
		let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Member

		// If appropriate, configure the new managed object.
		newManagedObject.name = newName

		// Save
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		delegate.saveContext()
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
		return sectionInfo.numberOfObjects
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

			// Save
			let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
			delegate.saveContext()
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let member = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Member
		self.delegate?.addMemberToGroup(member)
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Member
		cell.textLabel!.text = object.name
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
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			//println("Unresolved error \(error), \(error.userInfo)")
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

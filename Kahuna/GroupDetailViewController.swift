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

	@IBAction func showHistory(_ sender: AnyObject) {
		self.performSegue(withIdentifier: "showHistory", sender: nil);
	}


	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.current().userInterfaceIdiom == .pad {
			self.clearsSelectionOnViewWillAppear = false
			self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(GroupDetailViewController.insertNewObject(_:)))
		self.navigationItem.rightBarButtonItem = addButton
	}

	func configureView() {
        self.title = self.detailItem!.name
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(_ sender: AnyObject) {
		self.performSegue(withIdentifier: "addMember", sender: nil)
	}

	func addMemberToGroup(_ newMember: Member) {
		self.dismiss(animated: true, completion: nil)

		// If appropriate, configure the new managed object.
		if let group = detailItem {
			if !group.members.contains(newMember) {
				group.addMember(newMember)
			}
			else {
				//TODO: inform user about not adding an existing member
				//abort()
				let alertcontroller = UIAlertController(title: "Error", message: "User already exists in group", preferredStyle: .alert)
				alertcontroller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
				self.present(alertcontroller, animated: true, completion: nil)
				return
			}
		}

		let delegate = UIApplication.shared().delegate as! AppDelegate
		delegate.saveContext()
		self.tableView.reloadData()
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = self.fetchedResultsController.object(at: indexPath) as! Group
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

	func incrementPaymentCountForIndexPath(_ indexPath : IndexPath) {
		if let object = self.detailItem?.getMembers()[(indexPath as NSIndexPath).row] {
			let context = self.fetchedResultsController.managedObjectContext
			let newEvent = NSEntityDescription.insertNewObject(forEntityName: "Event", into: context) as! Event
			newEvent.member = object
			newEvent.timeStamp = Date()
			self.detailItem!.addPayment(newEvent)
			// Save the context.
			let delegate = UIApplication.shared().delegate as! AppDelegate
			delegate.saveContext()
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
//		return self.fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
//		return sectionInfo.numberOfObjects
		return self.detailItem?.getNumberOfMembers() ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
		self.configureCell(cell, atIndexPath: indexPath)
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false//true
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let context = self.fetchedResultsController.managedObjectContext
			context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)

			let delegate = UIApplication.shared().delegate as! AppDelegate
			delegate.saveContext()
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.incrementPaymentCountForIndexPath(indexPath)
		self.tableView.deselectRow(at: indexPath, animated: true)
		self.tableView.reloadData()
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		let object = self.detailItem?.getMembers()[(indexPath as NSIndexPath).row] as Member!
		cell.textLabel!.text = object?.name
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

	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}

		let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
		// Edit the entity name as appropriate.
		let entity = NSEntityDescription.entity(forEntityName: "Member", in: self.managedObjectContext!)
		fetchRequest.entity = entity

		// Set the batch size to a suitable number.
		fetchRequest.fetchBatchSize = 20

		// Edit the sort key as appropriate.
		let sortDescriptor = SortDescriptor(key: "name", ascending: false)

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
	var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
		case .delete:
			self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
		default:
			return
		}
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .fade)
			break
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .fade)
			break
		case .update:
			self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
			break
		case .move:
			tableView.deleteRows(at: [indexPath!], with: .fade)
			tableView.insertRows(at: [newIndexPath!], with: .fade)
			break
		}
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
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

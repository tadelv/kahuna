//
//  PaymentsHistoryViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import CoreData

class PaymentsHistoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var managedObjectContext: NSManagedObjectContext? = nil
	var detailItem: Group? {
		didSet {
			// Update the view.
			self.configureView()
		}
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
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}

	func configureView() {

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.detailItem?.getNumberOfPayments() ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
		self.configureCell(cell, atIndexPath: indexPath)
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if let elementToRemove = self.detailItem?.getPayments()[(indexPath as NSIndexPath).row] {
				self.detailItem?.removePayment(elementToRemove)

				let context = self.fetchedResultsController.managedObjectContext
				context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
				do {
					try context.save()
				} catch let error1 as NSError {
					var dict = [String: AnyObject]()
					dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
					dict[NSLocalizedFailureReasonErrorKey] = error1.localizedDescription
					dict[NSUnderlyingErrorKey] = error1
					let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
					// Replace this with code to handle the error appropriately.
					// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
					NSLog("Unresolved error \(error), \(error.userInfo)")
					abort()

				}
				self.tableView.reloadData()
			}
		}
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		if let object = self.detailItem?.getPayments()[(indexPath as NSIndexPath).row] {
			cell.textLabel!.text = "\(object.timeStamp)"
			cell.detailTextLabel!.text = object.member.name
		}
	}

	// MARK: - Fetched results controller

	var fetchedResultsController: NSFetchedResultsController {
		if _fetchedResultsController != nil {
			return _fetchedResultsController!
		}

		let fetchRequest = NSFetchRequest()
		// Edit the entity name as appropriate.
		let entity = NSEntityDescription.entity(forEntityName: "Event", in: self.managedObjectContext!)
		fetchRequest.entity = entity

		// Set the batch size to a suitable number.
		fetchRequest.fetchBatchSize = 20

		// Edit the sort key as appropriate.
		let sortDescriptor = SortDescriptor(key: "timeStamp", ascending: false)

		fetchRequest.sortDescriptors = [sortDescriptor]

		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
		aFetchedResultsController.delegate = self
		_fetchedResultsController = aFetchedResultsController

		do {
			try _fetchedResultsController!.performFetch()
		} catch let error1 as NSError {
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to perform fetch"
			dict[NSLocalizedFailureReasonErrorKey] = error1.localizedDescription
			dict[NSUnderlyingErrorKey] = error1
			let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(error), \(error.userInfo)")
			abort()
		}

		return _fetchedResultsController!
	}
	var _fetchedResultsController: NSFetchedResultsController? = nil

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

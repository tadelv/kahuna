//
//  MasterViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var detailViewController: GroupDetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = nil


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
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
			print("I have \(controllers)")
//		    self.detailViewController = controllers[controllers.count-1].topViewController as! GroupDetailViewController
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(_ sender: AnyObject) {
		let alertController = UIAlertController(title: "New", message: "", preferredStyle: UIAlertControllerStyle.alert)
		alertController.addTextField {(textField: UITextField!) in
			textField.placeholder = "Group name"
		}
		alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
			switch action.style{
			case .default:
				let textField = alertController.textFields?.first as UITextField!
				self.insertGroupWithName(textField?.text)

			case .cancel:
				print("cancel")

			case .destructive:
				print("destructive")
			}
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
			switch action.style{
			case .default:
				let textField = alertController.textFields?.first as UITextField!
				self.insertGroupWithName(textField?.text)
				break
			case .cancel:
				print("cancel")
				break
			case .destructive:
				print("destructive")
			}
		}))
		self.present(alertController, animated: true) { () -> Void in
		}
	}

	func insertGroupWithName(_ newName: String!) {
		let context = self.fetchedResultsController.managedObjectContext
		let entity = self.fetchedResultsController.fetchRequest.entity!
		let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context) as! Group

		// If appropriate, configure the new managed object.
		newManagedObject.name = newName
		let delegate = UIApplication.shared().delegate as! AppDelegate
		delegate.saveContext()
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		    let object = self.fetchedResultsController.object(at: indexPath) as! Group
		        let controller = segue.destinationViewController as! GroupDetailViewController
		        controller.detailItem = object
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		        controller.navigationItem.leftItemsSupplementBackButton = true
				controller.managedObjectContext = self.managedObjectContext
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
		return sectionInfo.numberOfObjects
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
		    let context = self.fetchedResultsController.managedObjectContext
		    context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)

			let delegate = UIApplication.shared().delegate as! AppDelegate
			delegate.saveContext()

		}
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		let object = self.fetchedResultsController.object(at: indexPath) as! Group
		cell.textLabel!.text = object.name
	}

	// MARK: - Fetched results controller

	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
	    if _fetchedResultsController != nil {
	        return _fetchedResultsController!
	    }
	    
	    let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
	    // Edit the entity name as appropriate.
	    let entity = NSEntityDescription.entity(forEntityName: "Group", in: self.managedObjectContext!)
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
		     // Replace this implementation with code to handle the error appropriately.
		     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	         //println("Unresolved error \(error), \(error.userInfo)")
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


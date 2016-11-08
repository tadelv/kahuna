//
//  MasterViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import RealmSwift

class MasterViewController: UITableViewController {

	var detailViewController: GroupDetailViewController? = nil
	var notificationToken: NotificationToken?
	let realm = try! Realm()


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
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
			print("I have \(controllers)")
//		    self.detailViewController = controllers[controllers.count-1].topViewController as! GroupDetailViewController
		}

		let results = realm.objects(Group.self)

		// Observe Results Notifications
		notificationToken = results.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
			guard let tableView = self?.tableView else { return }

//			switch changes {
//			case .Initial:
//				// Results are now populated and can be accessed without blocking the UI
//				tableView.reloadData()
//				break
//			case .Update(_, let deletions, let insertions, let modifications):
//				// Query results have changed, so apply them to the UITableView
//				tableView.beginUpdates()
//				tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) },
//					withRowAnimation: .Automatic)
//				tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
//					withRowAnimation: .Automatic)
//				tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) },
//					withRowAnimation: .Automatic)
//				tableView.endUpdates()
//				break
//			case .Error(let error):
//				// An error occurred while opening the Realm file on the background worker thread
//				fatalError("\(error)")
//				break
//			}
			tableView.reloadData()

		}

		self.tableView.reloadData()
	}

	deinit {
		notificationToken?.stop()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(sender: AnyObject) {
		let alertController = UIAlertController(title: "New", message: "", preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addTextFieldWithConfigurationHandler {(textField: UITextField!) in
			textField.placeholder = "Group name"
		}
		alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
			switch action.style{
			case .Default:
				let textField = alertController.textFields?.first as UITextField!
				self.insertGroupWithName(textField.text)

			case .Cancel:
				print("cancel")

			case .Destructive:
				print("destructive")
			}
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
			switch action.style{
			case .Default:
				let textField = alertController.textFields?.first as UITextField!
				self.insertGroupWithName(textField.text)
				break
			case .Cancel:
				print("cancel")
				break
			case .Destructive:
				print("destructive")
			}
		}))
		self.presentViewController(alertController, animated: true) { () -> Void in
		}
	}

	func insertGroupWithName(newName: String!) {
		let group = Group(name: newName)
		do {
			try realm.write {
				realm.add(group)

			}
		}
		catch let error {
			print("failed to add group \(group.name): \(error)")
		}
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			let results = realm.objects(Group)
		    if let indexPath = self.tableView.indexPathForSelectedRow {
				let group = results[indexPath.row]
		        let controller = segue.destinationViewController as! GroupDetailViewController
		        controller.detailItem = group
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return realm.objects(Group).count > 0 ? 1 : 0
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let results = realm.objects(Group)
		return results.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		self.configureCell(cell, atIndexPath: indexPath)
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
		    let group = realm.objects(Group)[indexPath.row]
			do {
				try realm.write({ 
					realm.delete(group)
				})
			} catch let error {
				print("failed to delete group \(group): \(error)")
			}

		}
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		let object = realm.objects(Group)[indexPath.row]
		cell.textLabel!.text = object.name
	}
}


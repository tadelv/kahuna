//
//  AddUserTableViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import RealmSwift

protocol AddUserControllerDelegate {
	func addMemberToGroup(newMember: Member)
}

class AddUserTableViewController: UITableViewController {

	let realm = try! Realm()
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
		let newMember = Member(name: newName)
		do {
			try self.realm.write({
				self.realm.add(newMember)
			})
		} catch let error {
			print("failed to add new memeber: \(error)")
		}
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.realm.objects(Member).count ?? 0
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let members = realm.objects(Member)
		return members.count
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
//			TODO: realm delete member
//			let context = self.fetchedResultsController.managedObjectContext
//			context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
//
//			// Save
//			let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//			delegate.saveContext()
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let member = self.realm.objects(Member)[indexPath.row]
		self.delegate?.addMemberToGroup(member)
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		let object = self.realm.objects(Member)[indexPath.row]
		cell.textLabel!.text = object.name
	}

}

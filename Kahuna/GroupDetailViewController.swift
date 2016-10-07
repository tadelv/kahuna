//
//  GroupDetailViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit

class GroupDetailViewController: UITableViewController, AddUserControllerDelegate {

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
			if !group.members.contains(newMember) {
				group.members.append(newMember)
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

	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let _ = self.tableView.indexPathForSelectedRow {
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				controller.detailItem = self.detailItem!
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
		if segue.identifier == "addMember" {
			let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AddUserTableViewController
			controller.delegate = self
		}
		if segue.identifier == "showHistory" {
			let controller = segue.destinationViewController as! PaymentsHistoryViewController
			controller.detailItem = self.detailItem
		}
	}

	func incrementPaymentCountForIndexPath(indexPath : NSIndexPath) {
		if let payingMember = self.detailItem?.members[indexPath.row] {
			let newEvent = Event(member: payingMember)
			self.detailItem!.payments.append(newEvent)
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
		return self.detailItem?.members.count ?? 0
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
			// TODO:
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.incrementPaymentCountForIndexPath(indexPath)
		self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
		self.tableView.reloadData()
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		let object = self.detailItem?.members[indexPath.row] as Member!
		cell.textLabel!.text = object.name
		if let payments = self.detailItem?.payments {
			var paymentsCount = 0
			for pEvent in payments {
				if pEvent.member == object {
					paymentsCount += 1
				}
			}
			cell.detailTextLabel!.text = "\(paymentsCount)"
		}

	}

}

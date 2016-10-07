//
//  PaymentsHistoryViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import RealmSwift

class PaymentsHistoryViewController: UITableViewController {


	let realm = try! Realm()
	var detailItem: Group? {
		didSet {
			// Update the view.
			self.configureView()
		}
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

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.detailItem?.payments.count ?? 0
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
			if let elementToRemove = self.detailItem?.payments[indexPath.row] {
				do {
					try realm.write({ 
						realm.delete(elementToRemove)
					})
				} catch let error {
					print("failed to remove \(elementToRemove): \(error)")
				}
				self.tableView.reloadData()
			}
		}
	}

	func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
		if let object = self.detailItem?.payments[indexPath.row] {
			cell.textLabel!.text = "\(object.timeStamp)"
			cell.detailTextLabel!.text = object.member!.name
		}
	}
}

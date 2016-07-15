//
//  PaymentsHistoryViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit

class PaymentsHistoryViewController: UITableViewController {

	var detailItem: Group? {
		didSet {
			// Update the view.
			self.configureView()
		}
	}

	var groupPayments: [Event] = []


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
		// TODO: Get all events from Realms
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
		return self.groupPayments.count
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
			// TODO: Perform Realm remove element
			let paymentToRemove = self.detailItem!.payments.remove(at: indexPath.row)
			
			abort()
		}
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		let object = self.groupPayments[indexPath.row]
		cell.textLabel!.text = "\(object.timeStamp)"
		cell.detailTextLabel!.text = object.member!.name
	}

}

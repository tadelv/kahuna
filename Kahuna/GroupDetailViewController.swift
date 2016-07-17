//
//  GroupDetailViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import Realm

class GroupDetailViewController: UITableViewController, AddUserControllerDelegate {

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
		self.tableView.reloadData()
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
			if !group.contains(newMember) {
				group.members.add(newMember)
				let realm = RLMRealm.default()
				realm.beginWriteTransaction()
				realm.addOrUpdate(group)
				try! realm.commitWriteTransaction()
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

		// TODO: save Realm
		self.tableView.reloadData()
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let _ = self.tableView.indexPathForSelectedRow {
				// FIXME: what is this? Remove from storyboard or reorganize
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				controller.detailItem = self.detailItem
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

	func incrementPaymentCountForIndexPath(_ indexPath : IndexPath) {
		let index = UInt(indexPath.row)
		if index < self.detailItem?.members.count {
			if let object = self.detailItem?.members.object(at: index) as? Member {
				let newEvent = Event()
				newEvent.member = object
				self.detailItem!.payments.add(newEvent)
				let realm = RLMRealm.default()
				realm.beginWriteTransaction()
				realm.addOrUpdateObjects(fromArray: [newEvent, object, self.detailItem!])
				do {
					try realm.commitWriteTransaction()
				} catch let error as RLMError {
					print("Failed to write: \(error)")
				} catch let error as Any {
					print("Failed with \(error)")
				}
			}
		}

	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let count = self.detailItem?.members.count {
			return Int(count)
		}
		return 0
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
			// TODO: get member at index and remove from group
			// and save Realm!
			abort()
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.incrementPaymentCountForIndexPath(indexPath)
		self.tableView.deselectRow(at: indexPath, animated: true)
		self.tableView.reloadData()
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		if let member = self.detailItem?.members[UInt(indexPath.row)] as? Member {
			cell.textLabel!.text = member.name
			let predicate = Predicate(format: "member.name == \(member.name)", argumentArray: nil)
			if let payments = self.detailItem?.payments.objects(with: predicate) {
				cell.detailTextLabel!.text = "\(payments.count)"
			}
		}

	}
}

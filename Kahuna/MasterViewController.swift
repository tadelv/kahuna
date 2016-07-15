//
//  MasterViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

	var detailViewController: GroupDetailViewController? = nil
	var groups: [Group] = []


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

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
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
				if let textField = alertController.textFields?.first {
					self.insertGroupWithName(textField.text)
				}

			case .cancel:
				print("cancel")

			case .destructive:
				print("destructive")
			}
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
			switch action.style{
			case .default:
				if let textField = alertController.textFields?.first {
					self.insertGroupWithName(textField.text)
				}
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
		let newGroup = Group()
		newGroup.name = newName
		// TODO: Realm save
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = self.groups[indexPath.row]
		        let controller = segue.destinationViewController as! GroupDetailViewController
		        controller.detailItem = object
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.groups.count
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
			// TODO: remove group from realm and save
			abort()
		}
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		let object = self.groups[indexPath.row]
		cell.textLabel!.text = object.name
	}

}


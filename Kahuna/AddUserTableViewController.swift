//
//  AddUserTableViewController.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit

protocol AddUserControllerDelegate {
	func addMemberToGroup(_ newMember: Member)
}

class AddUserTableViewController: UITableViewController {

	var delegate: AddUserControllerDelegate? = nil

	var allMembers: [Member] = []


	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.clearsSelectionOnViewWillAppear = false
			self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddUserTableViewController.dismiss(_:)))
		self.navigationItem.leftBarButtonItem = cancelButtonItem

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(AddUserTableViewController.insertNewObject(_:)))
		self.navigationItem.rightBarButtonItem = addButton
	}

	func configureView() {

	}

	func dismiss(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func insertNewObject(_ sender: AnyObject) {
		let alertController = UIAlertController(title: "New", message: "", preferredStyle: UIAlertControllerStyle.alert)
		alertController.addTextField {(textField: UITextField!) in
			textField.placeholder = "Group member"
		}
		alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
			let textField = alertController.textFields?.first as UITextField!
			self.insertMemberWithName(textField?.text)
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
		}))
		self.present(alertController, animated: true) { () -> Void in
		}
	}

	func insertMemberWithName(_ newName: String!) {
		let newMember = Member()
		newMember.name = newName
		// TODO: add new member to realm
	}

	// MARK: - Segues

	func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {

	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.allMembers.count
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
			"Unimplemented delete editing style"
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let member = self.allMembers[indexPath.row]
		self.delegate?.addMemberToGroup(member)
	}

	func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
		let object = self.allMembers[indexPath.row]
		cell.textLabel!.text = object.name
	}

}

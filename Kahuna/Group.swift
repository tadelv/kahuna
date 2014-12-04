//
//  Group.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation
import CoreData

class Group: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var members: NSSet
    @NSManaged var payments: NSSet

}

extension Group {

	func addMember(newMember:Member) {
		var teamz = self.mutableSetValueForKey("members")
		teamz.addObject(newMember)
	}

	func getNumberOfMembers() -> Int {
		return self.members.count;
	}

	func getMembers() -> [Member] {
		var tmpsak: [Member]
		tmpsak = self.members.allObjects as [Member]
		return tmpsak
	}

	func addPayment(newPayment:Event) {
		var teamz = self.mutableSetValueForKey("payments")
		teamz.addObject(newPayment)
	}

	func removePayment(payment: Event) {
		var teamz = self.mutableSetValueForKey("payments")
		teamz.removeObject(payment)
	}

	func getNumberOfPayments() -> Int {
		return self.payments.count;
	}

	func getPayments() -> [Event] {
		var tmpsak: [Event]
		tmpsak = self.payments.allObjects as [Event]
		return tmpsak
	}

}
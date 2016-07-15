//
//  Group.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation

class Group {

	var name: String?
    var members: [Member] = []
	var payments: [Event] = []

	func contains(_ m:Member) -> Bool {
		for otherMember in members {
			if otherMember.name == m.name {
				return true
			}
		}
		return false
	}

}
/*
extension Group {

	func addMember(_ newMember:Member) {
		let teamz = self.mutableSetValue(forKey: "members")
		teamz.add(newMember)
	}

	func getNumberOfMembers() -> Int {
		return self.members.count;
	}

	func getMembers() -> [Member] {
		var tmpsak: [Member]
		tmpsak = self.members.allObjects as! [Member]
		return tmpsak
	}

	func addPayment(_ newPayment:Event) {
		let teamz = self.mutableSetValue(forKey: "payments")
		teamz.add(newPayment)
	}

	func removePayment(_ payment: Event) {
		let teamz = self.mutableSetValue(forKey: "payments")
		teamz.remove(payment)
	}

	func getNumberOfPayments() -> Int {
		return self.payments.count;
	}

	func getPayments() -> [Event] {
		var tmpsak: [Event]
		tmpsak = self.payments.allObjects as! [Event]
		return tmpsak
	}

}
*/

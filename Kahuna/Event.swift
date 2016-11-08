//
//  Event.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation
import RealmSwift

class Event : Object {

    dynamic var timeStamp: NSDate = NSDate()
    dynamic var member: Member?
	dynamic var uuid: NSString = NSUUID().UUIDString

	convenience init(member: Member) {
		self.init()
		self.member = member
	}

	override class func primaryKey() -> String? { return "uuid" }

}

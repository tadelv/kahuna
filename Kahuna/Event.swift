//
//  Event.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation
import Realm

class Event: RLMObject {

	var timeStamp: Date
	var member: Member?
	let uuid: String

	override init() {
		self.uuid = UUID().uuidString
		self.timeStamp = Date()
		super.init()
	}

	override class func primaryKey() -> String {
		return "uuid"
	}

}

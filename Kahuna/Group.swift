//
//  Group.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object {

    dynamic var name: String = ""
    let members = List<Member>()
    let payments = List<Event>()

	convenience init(name: String) {
		self.init()
		self.name = name
	}

}
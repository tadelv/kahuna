//
//  Member.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation
import RealmSwift

class Member: Object {

    dynamic var name = ""

	convenience init(name: String) {
		self.init()
		self.name = name
	}

}

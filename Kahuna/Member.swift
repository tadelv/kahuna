//
//  Member.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation

class Member {

    var name: String?

}

func == (left: Member, right: Member) -> Bool {
	return left.name == right.name
}

func != (left: Member, right: Member) -> Bool {
	return !(left == right)
}

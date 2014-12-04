//
//  Event.swift
//  Kahuna
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import Foundation
import CoreData

class Event: NSManagedObject {

    @NSManaged var timeStamp: NSDate
    @NSManaged var member: Member

}

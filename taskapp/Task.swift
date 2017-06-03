//
//  Task.swift
//  taskapp
//
//  Created by yamamoto yasuhiro on 2017/05/31.
//  Copyright © 2017年 mochimochinoki. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object{
    dynamic var id = 0
    dynamic var title = ""
    dynamic var contents = ""
    dynamic var date = NSDate()
    dynamic var category = ""
    override static func primaryKey() -> String?{
        return "id"
    }
}

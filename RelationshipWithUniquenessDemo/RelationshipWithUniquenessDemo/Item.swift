//
//  Item.swift
//  RelationshipWithUniquenessDemo
//
//  Created by shinolr on 2024/1/26.
//

import Foundation
import SwiftData

let departmentName = "department A"
let employeeName = "person 1"
let departmentID = 1001
let employeeID = 1002

@Model
final class Department {
  @Attribute(.unique)
  var id: Int
  var name: String

  @Relationship(inverse: \Employee.department)
  var employees: [Employee]?
  var info: Info?

  init(id: Int, name: String) {
    self.id = id
    self.name = name
    self.info = Info(id: id)
  }
}

@Model
final class Employee {
  @Attribute(.unique)
  var id: Int
  var name: String

  var department: Department?
  var info: Info?

  init(id: Int, name: String) {
    self.id = id
    self.name = name
    self.info = Info(id: id)
  }
}

@Model
final class Info {
  @Attribute(.unique)
  var id: Int

  var department: Department?
  var employee: Employee?

  init(id: Int) {
    self.id = id
  }
}


//
//  Store.swift
//  RelationshipWithUniquenessDemo
//
//  Created by shinolr on 2024/1/26.
//

import Foundation
import SwiftData
import Observation

@Observable
class Store {
  @ObservationIgnored
  private let swiftDataStack = SwiftDataStack.live

  var departments: [Department] = []

  func addDepartment() async {
    let department = Department(id: departmentID, name: departmentName)
    do {
      try await swiftDataStack.add(department: department)
    } catch {
      fatalError("\(error)")
    }

    await retrieve()
  }

  func addEmployee() async {
    let employee = Employee(id: employeeID, name: employeeName)
    do {
      try await swiftDataStack.add(employee: employee)
    } catch {
      fatalError("\(error)")
    }

    await retrieve()
  }

  @MainActor
  func retrieve() async {
    let predicate = #Predicate<Department> { $0.name == departmentName }
    do {
      departments = try await swiftDataStack.retrieve(predicate: predicate, sortBy: [])
    } catch {
      fatalError("\(error)")
    }
  }
}

private final class SwiftDataStack {
  let modelContainer: ModelContainer

  init(inMemory: Bool) {
    let schema = Schema(
      [
        Department.self,
        Employee.self,
        Info.self,
      ]
    )
    let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
    modelContainer = try! ModelContainer(for: schema, configurations: configuration)
  }

  static let live = SwiftDataStack(inMemory: false)

  private lazy var modelActor = Handler(modelContainer: modelContainer)

  func add(department: Department) async throws {
    try await modelActor.add(department: department)
  }

  func add(employee: Employee) async throws {
    try await modelActor.add(employee: employee)
  }

  func retrieve<T>(
    predicate: Predicate<T>? = nil,
    sortBy sortDescriptors: [SortDescriptor<T>] = []
  ) async throws -> [T] where T: PersistentModel {
    try await modelActor.retrieve(predicate: predicate, sortBy: sortDescriptors)
  }

  func _retrieve<T>(
    predicate: Predicate<T>? = nil,
    sortBy sortDescriptors: [SortDescriptor<T>] = []
  ) async throws -> [T] where T: PersistentModel {
    try await modelActor._retrieve(predicate: predicate, sortBy: sortDescriptors)
  }
}

@ModelActor
fileprivate actor Handler {
  func add(department: Department) throws {
    modelContext.insert(department)

    saveContext()
  }

  func add(employee: Employee) throws {
    guard let existing: Department = try modelContext.fetch(
      .init(predicate: #Predicate {
        $0.name == departmentName
      })
    ).first else {
      return
    }

    employee.department = existing
    modelContext.insert(employee)

    saveContext()
  }

  @MainActor
  func retrieve<T>(
    predicate: Predicate<T>? = nil,
    sortBy sortDescriptors: [SortDescriptor<T>] = []
  ) throws -> [T] where T: PersistentModel {
    let fetchDescriptor = FetchDescriptor(
      predicate: predicate,
      sortBy: sortDescriptors
    )
    return try modelContainer.mainContext.fetch(fetchDescriptor)
  }

  func _retrieve<T>(
    predicate: Predicate<T>? = nil,
    sortBy sortDescriptors: [SortDescriptor<T>] = []
  ) throws -> [T] where T: PersistentModel {
    let fetchDescriptor = FetchDescriptor(
      predicate: predicate,
      sortBy: sortDescriptors
    )
    return try modelContext.fetch(fetchDescriptor)
  }

  func saveContext() {
    do {
      guard modelContext.hasChanges else { return }
      try modelContext.save()
    } catch {
      fatalError("\(error)")
    }
  }
}

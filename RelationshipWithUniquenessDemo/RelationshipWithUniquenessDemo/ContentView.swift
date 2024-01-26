//
//  ContentView.swift
//  RelationshipWithUniquenessDemo
//
//  Created by shinolr on 2024/1/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(Store.self) var store

  var body: some View {
    NavigationStack {
      List {
        ForEach(store.departments) { department in
          Section(department.name) {
            ForEach(department.employees ?? []) { employee in
              Text(employee.name)
            }
          }
        }
      }
      .toolbar {
        ToolbarItem {
          Button {
            Task {
              await store.addEmployee()
            }
          } label: {
            Label("Add Department", systemImage: "plus")
          }
        }
      }
    }
    .task { await store.addDepartment() }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Department.self, inMemory: true)
}

//
//  multitoc.swift
//  Multitoc
//
//  Created by Alex Khuala on 24.04.24.
//

import SwiftUI

@main
struct multitoc: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

/*
 
 ,{
     "label": "beta",
     "children": [
         {
             "label": "Workspace A",
             "children": [
                 { "id": "beta.A.1", "label": "Entry 1" },
                 { "id": "beta.A.2", "label": "Entry 2" },
                 { "id": "beta.A.3", "label": "Entry 3" },
                 {
                     "label": "Entry 4",
                     "children": [
                         { "id": "multitoc.A.4.1", "label": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." },
                         { "id": "beta.A.4.2", "label": "Sub-Entry 1" },
                         { "id": "beta.A.4.3", "label": "Sub-Entry 1" },
                     ]
                 }
             ]
         },
         {
             "label": "Workspace B",
             "children": [
                 { "id": "beta.B.1", "label": "Entry 1" },
                 { "id": "beta.B.2", "label": "Entry 2" },
                 { "id": "beta.B.3", "label": "Entry 3" },
                 {
                     "label": "Entry 4",
                     "children": [
                         { "id": "beta.A.4.1", "label": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." },
                         { "id": "beta.B.4.2", "label": "Sub-Entry 2" },
                         { "id": "beta.B.4.3", "label": "Sub-Entry 3" },
                         { "id": "beta.B.4.4", "label": "Sub-Entry 4" },
                         { "id": "beta.B.4.5", "label": "Sub-Entry 5" },
                         { "id": "beta.B.4.6", "label": "Sub-Entry 6" },
                         { "id": "beta.B.4.7", "label": "Sub-Entry 7" }
                     ]
                 }
                 { "id": "beta.B.5", "label": "Entry 5" },
                 { "id": "beta.B.6", "label": "Entry 6" }
             ]
         }
     ]
 },{
     "label": "gamma",
     "children": [
         {
             "label": "Workspace A",
             "children": [
                 { "id": "gamma.A.1", "label": "Entry 1" },
                 { "id": "gamma.A.2", "label": "Entry 2" },
                 { "id": "gamma.A.3", "label": "Entry 3" },
                 {
                     "label": "Entry 4",
                     "children": [
                         { "id": "gamma.A.4.1", "label": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." },
                         { "id": "gamma.A.4.2", "label": "Sub-Entry 2" },
                         { "id": "gamma.A.4.3", "label": "Sub-Entry 3" },
                         { "id": "gamma.A.4.4", "label": "Sub-Entry 4" },
                         { "id": "gamma.A.4.5", "label": "Sub-Entry 5" }
                     ]
                 }
             ]
         },
         {
             "label": "Workspace B",
             "children": [
                 { "id": "gamma.B.1", "label": "Entry 1" },
                 { "id": "gamma.B.2", "label": "Entry 2" },
                 { "id": "gamma.B.3", "label": "Entry 3" },
                 {
                     "label": "Entry 4",
                     "children": [
                         { "id": "gamma.A.4.1", "label": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." },
                         { "id": "gamma.B.4.2", "label": "Sub-Entry 2" },
                         { "id": "gamma.B.4.3", "label": "Sub-Entry 3" },
                         { "id": "gamma.B.4.4", "label": "Sub-Entry 4" },
                         { "id": "gamma.B.4.5", "label": "Sub-Entry 5" }
                     ]
                 }
                 { "id": "gamma.B.5", "label": "Entry 5" },
                 { "id": "gamma.B.6", "label": "Entry 6" },
                 { "id": "gamma.B.7", "label": "Entry 7" }
             ]
         }
     ]
 }
 */

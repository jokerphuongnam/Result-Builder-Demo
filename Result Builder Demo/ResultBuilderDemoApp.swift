//
//  ResultBuilderDemoApp.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import SwiftUI

@main
struct ResultBuilderDemoApp: App {
    var body: some Scene {
        WindowGroup {
            LoginView(network: DataNetwork())
        }
    }
}

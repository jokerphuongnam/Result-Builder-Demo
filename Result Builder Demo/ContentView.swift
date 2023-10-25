//
//  ContentView.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ScrollView {
            TextField(text: $username) {
                Text("Username")
                    .padding(16)
                    .border(.black, width: 1)
                    .cornerRadius(16)
            }
        }
        .refreshable {
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

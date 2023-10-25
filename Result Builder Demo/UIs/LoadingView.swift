//
//  LoadingView.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    Text("Loading...")
                    ProgressView()
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }
}

struct LoadingView_Preview: PreviewProvider {
    @State static var isLoading = true
    static var previews: some View {
        LoadingView(isShowing: $isLoading) {
            Text("Text")
        }
    }
}

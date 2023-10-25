//
//  TextFieldLabel.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import SwiftUI
import RxSwift

struct LoginView: View {
    private var network: PDataNetwork
    private let disposeBag = DisposeBag()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading =  false
    @State private var result: Result<String, Error>? = nil
    
    init(network: PDataNetwork) {
        self.network = network
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                
                Text("Logo")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .fontWeight(.black)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                HStack {
                    Text("Email:")
                        .multilineTextAlignment(.leading)
                        .frame(width: 100)
                    
                    TextField(text: $email) {
                        Text("Required")
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 2)
                    )
                }
                
                Spacer()
                    .frame(height: 16.0)
                
                HStack {
                    Text("Password:")
                        .multilineTextAlignment(.leading)
                        .frame(width: 100)
                    
                    SecureField(text: $password) {
                        Text("Required")
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 2)
                    )
                }
                
                Spacer()
                    .frame(height: 16)
                
                Button {
                    login()
                } label: {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(8)
                    
                }
                
                if let result = result {
                    switch result {
                    case .success(let data):
                        Text(data)
                    case .failure(let error):
                        Text(error.localizedDescription)
                    }
                }
                
                Spacer()
            }
            
        }
        .padding(.horizontal, 16.0)
    }
    
    private func login() {
        isLoading = true
        network.login(email: email, password: password)
            .subscribe(on: SerialDispatchQueueScheduler.init(qos: .utility))
            .observe(on: MainScheduler.instance)
            .subscribe { networkResult in
                isLoading = false
                switch networkResult {
                case .success(let data):
                    result = .success("\(data.statusCode)")
                case .failure(let error):
                    result = .failure(error)
                }
            }
            .disposed(by: disposeBag)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(network: DataNetwork())
    }
}

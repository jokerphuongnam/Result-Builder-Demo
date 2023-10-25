//
//  DataNetwork.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import Foundation
import RxSwift

struct LoginResponse {
    let id, email, name: String
    let gender: String
    let token: String
}

extension LoginResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email, name, gender
        case token
    }
}

@frozen public struct ApiResponse<T> where T: Codable {
    let statusCode: Int
    let status: Bool
    let message: String
    let data: T!
}

extension ApiResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case status, message, data
    }
}


protocol PDataNetwork {
//    func login(email: String, password: String) -> Single<ApiResponse<LoginResponse>>
    func login(email: String, password: String) -> Single<NetworkResponse<ApiResponse<LoginResponse>>>
}

final class DataNetwork: PDataNetwork {
//    @NetworkBuilder<ApiResponse<LoginResponse>>
//    func login(email: String, password: String) -> Single<ApiResponse<LoginResponse>> {
//        BaseURL("https://notes-api-staging.herokuapp.com/")
//
//        PostMethod("login")
//
//        RequestBody(key: "email", value: email)
//        RequestBody(key: "password", value: password)
//    }
    
    @NetworkBuilder<ApiResponse<LoginResponse>>
    func login(email: String, password: String) -> Single<NetworkResponse<ApiResponse<LoginResponse>>> {
        BaseURL("https://api-football-v1.p.rapidapi.com/v3/")
        
        GetMethod("fixtures")
        
        HttpHeader(key: "X-RapidAPI-Key", value: "7e76f10e3dmsh6b473751bf05c55p1480d5jsnbeaf3617ab9a")
        HttpHeader(key: "X-RapidAPI-Host", value: "api-football-v1.p.rapidapi.com")
        
        RequestQuery(key: "league", value: 39)
        RequestQuery(key: "season", value: 2020)
    }
}

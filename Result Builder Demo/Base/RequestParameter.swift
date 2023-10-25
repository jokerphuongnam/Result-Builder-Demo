//
//  RequestParameter.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import Alamofire

protocol RequestParameter {
    
}

struct BaseURL: RequestParameter {
    let baseURL: String
    
    init(_ baseURL: String) {
        self.baseURL = baseURL
    }
}

struct RequestQuery: RequestParameter {
    var key: String
    var value: Any
}

struct HttpHeader: RequestParameter {
    let key, value: String
}

struct Interceptor: RequestParameter {
    let interceptor: RequestInterceptor
    
    init(_ interceptor: RequestInterceptor) {
        self.interceptor = interceptor
    }
}

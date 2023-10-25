//
//  RequestMethod.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import Alamofire

protocol RequestMethod: RequestParameter {
    var httpMethod: HTTPMethod { get }
    var path: String { get }
}

/// `CONNECT` method.
struct ConnectMethod: RequestMethod {
    var httpMethod: HTTPMethod = .connect
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `DELETE` method.
struct DeleteMethod: RequestMethod {
    var httpMethod: HTTPMethod = .delete
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `GET` method.
struct GetMethod: RequestMethod {
    var httpMethod: HTTPMethod = .get
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `HEAD` method.
struct HeadMethod: RequestMethod {
    var httpMethod: HTTPMethod = .head
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `OPTIONS` method.
struct OptionsMethod: RequestMethod {
    var httpMethod: HTTPMethod = .options
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `PATCH` method.
struct PatchMethod: RequestMethod {
    var httpMethod: HTTPMethod = .patch
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `POST` method.
struct PostMethod: RequestMethod {
    var httpMethod: HTTPMethod = .post
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `PUT` method.
struct PutMethod: RequestMethod {
    var httpMethod: HTTPMethod = .put
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `QUERY` method.
struct QueryMethod: RequestMethod {
    var httpMethod: HTTPMethod = .query
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `TRACE` method.
struct TraceMethod: RequestMethod {
    var httpMethod: HTTPMethod = .trace
    var path: String
    
    init(_ path: String) {
        self.path = path
    }
}

/// `Custom` metod
struct CustomMethod: RequestMethod {
    var httpMethod: HTTPMethod
    var path: String
    
    init(method: String, _ path: String) {
        self.httpMethod = .init(rawValue: method)
        self.path = path
    }
}

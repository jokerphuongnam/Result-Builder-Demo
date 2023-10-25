//
//  RequestBody.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import Foundation

enum BodyType {
    case keyValue(key: String, value: Any)
    case dictionary(Dictionary<String, Any>)
    case object(JSONAble)
}

struct RequestBody: RequestParameter {
    let body: BodyType
    
    init(key: String, value: Any) {
        body = .keyValue(key: key, value: value)
    }
    
    init(_ dictionary: Dictionary<String, Any>) {
        body = .dictionary(dictionary)
    }
    
    init<T>(_ object: T) where T: JSONAble {
        body = .object(object)
    }
}

protocol JSONAble {}

extension JSONAble {
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}

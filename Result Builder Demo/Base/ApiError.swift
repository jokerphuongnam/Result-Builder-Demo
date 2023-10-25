//
//  ApiError.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import Foundation

enum ApiError: Error {
    case dataNotExist
    case statusCodeNotExist
    case cannotParseData
}

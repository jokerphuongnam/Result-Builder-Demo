//
//  NetworkBuilder.swift
//  Result Builder Demo
//
//  Created by pnam on 23/01/2023.
//

import Alamofire
import RxSwift

class Request {
    var baseUrl: String = ""
    var method: HTTPMethod = .get
    var path: String = ""
    var httpParameters: Parameters = [:]
    var httpHeaderFields: HTTPHeaders = [:]
    var interceptor: RequestInterceptor? = nil
    var encoding: ParameterEncoding = URLEncoding.default
}

extension Request {
    var baseURL: URL {
        URL(string: baseUrl)!
    }
    
    var url: URL {
        baseURL.appendingPathComponent(path)
    }
    
    convenience init(_ paramters: [RequestParameter]) {
        self.init()
        
        var query = [String: Any]()
        var body = [String: Any]()
        for paramter in paramters {
            if let paramter = paramter as? RequestMethod {
                self.method = paramter.httpMethod
                self.path = paramter.path
            } else if let paramter = paramter as? BaseURL {
                self.baseUrl = paramter.baseURL
            } else if let paramter = paramter as? RequestBody {
                switch paramter.body {
                case .keyValue(key: let key, value: let value):
                    body[key] = value
                case .dictionary(let dictionary):
                    body.merge(dictionary)
                case .object(let object):
                    let dictionary = object.toDict()
                    body.merge(dictionary)
                }
            } else if let paramter = paramter as? RequestQuery {
                query[paramter.key] = paramter.value
            } else if let paramter = paramter as? HttpHeader {
                self.httpHeaderFields[paramter.key] = paramter.value
            } else if let paramter = paramter as? Interceptor {
                self.interceptor = paramter.interceptor
            }
        }
        
        httpParameters.merge(query)
        httpParameters.merge(body)
        encoding = NetworkEncoding(queryParameters: query, bodyParameters: body)
    }
}


@resultBuilder
struct NetworkBuilder<Response> where Response: Decodable {
    static func buildBlock(_ paramters: RequestParameter...) -> Single<Response> {
        Single.create { observer in
            let request = send(request: .init(paramters)) { result in
                switch result {
                case .success(let res):
                    observer(.success(res))
                case .failure(let error):
                    observer(.failure(error))
                }
            } success: { completion, statusCode, response in
                completion(.success(response))
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    static func buildBlock(_ paramters: RequestParameter...) -> Single<NetworkResponse<Response>> {
        Single.create { observer in
            let request = send(request: .init(paramters)) { result in
                switch result {
                case .success(let res):
                    observer(.success(res))
                case .failure(let error):
                    observer(.failure(error))
                }
            } success: { completion, statusCode, response in
                completion(.success(NetworkResponse(statusCode: statusCode, data: response)))
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

private extension NetworkBuilder {
    typealias NetworkCompletion<Response> = (Result<Response, Error>) -> ()
    
    @discardableResult
    static func send<NetworkResponse>(
        request: Request,
        completion: @escaping NetworkCompletion<NetworkResponse>,
        success: @escaping(_ completion: NetworkCompletion<NetworkResponse>, _ statusCode: Int, _ response: Response) -> ()
    ) -> DataRequest where NetworkResponse: Decodable {
        AF.request(
            request.url,
            method: request.method,
            parameters: request.httpParameters,
            encoding: request.encoding,
            headers: request.httpHeaderFields,
            interceptor: request.interceptor
        )
        .cURLDescription(on: DispatchQueue.init(label: "\(self.self)", qos: .background)) { description in
#if DEBUG
            print("Request \(description)")
#endif
        }
        .responseDecodable(of: NetworkResponse.self) { response in
            guard let data = response.data else {
                completion(.failure(ApiError.dataNotExist))
                return
            }
            guard let statusCode = response.response?.statusCode else {
                completion(.failure(ApiError.statusCodeNotExist))
                return
            }
            do {
                let res = try JSONDecoder().decode(Response.self, from: data)
                success(completion, statusCode, res)
            } catch  {
                completion(.failure(ApiError.cannotParseData))
            }
        }
    }
}

@frozen public struct NetworkResponse<T>: Decodable where T: Decodable {
    let statusCode: Int
    let data: T!
}

private extension Dictionary {
    mutating func merge(_ dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}


private struct NetworkEncoding: ParameterEncoding {
    var queryParameters: [String: Any]
    var bodyParameters: [String: Any]
    
    func encode<Parameters>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest where Parameters : Encodable {
        var urlRequest = request.urlRequest!
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
        } catch {
            print(error.localizedDescription)
        }
        return urlRequest
    }
    
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard parameters != nil else { return urlRequest }
        
        guard let url = urlRequest.url else {
            throw AFError.parameterEncodingFailed(reason: .missingURL)
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !queryParameters.isEmpty {
            let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(queryParameters)
            urlComponents.percentEncodedQuery = percentEncodedQuery
            urlRequest.url = urlComponents.url
        }
        
        if !bodyParameters.isEmpty {
            if urlRequest.headers["Content-Type"] == nil {
                urlRequest.headers.update(.contentType("application/x-www-form-urlencoded; charset=utf-8"))
            }
            urlRequest.httpBody = Data(query(bodyParameters).utf8)
        }
        
        return urlRequest
    }
    
    /// Creates a percent-escaped, URL encoded query string components from the given key-value pair recursively.
    ///
    /// - Parameters:
    ///   - key:   Key of the query component.
    ///   - value: Value of the query component.
    ///
    /// - Returns: The percent-escaped, URL encoded query string components.
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        switch value {
        case let dictionary as [String: Any]:
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        case let array as [Any]:
            for (_, value) in array.enumerated() {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        case let number as NSNumber:
            if number.isBool {
                components.append((escape(key), escape(boolEncode(value: number.boolValue))))
            } else {
                components.append((escape(key), escape("\(number)")))
            }
        case let bool as Bool:
            components.append((escape(key), escape(boolEncode(value: bool))))
        default:
            components.append((escape(key), escape("\(value)")))
        }
        return components
    }
    
    /// Creates a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// - Parameter string: `String` to be percent-escaped.
    ///
    /// - Returns:          The percent-escaped `String`.
    public func escape(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) ?? string
    }
    
    private func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private func boolEncode(value: Bool) -> String {
        value ? "1" : "0"
    }
}

extension NSNumber {
    fileprivate var isBool: Bool {
        // Use Obj-C type encoding to check whether the underlying type is a `Bool`, as it's guaranteed as part of
        // swift-corelibs-foundation, per [this discussion on the Swift forums](https://forums.swift.org/t/alamofire-on-linux-possible-but-not-release-ready/34553/22).
        String(cString: objCType) == "c"
    }
}

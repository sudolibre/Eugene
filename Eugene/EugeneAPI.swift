//
//  PresenceAPI.swift
//  Presence
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

enum RequestResult {
    case success(Dictionary<String, Any>)
    case networkFailure(HTTPURLResponse)
    case systemFailure(Error)
}


internal final class EugeneAPI {
    
    private static let baseURL = "https://eugene-tiy.herokuapp.com"
    
    enum RequestType: String {
        case get = "GET", post = "POST"
    }

    enum Endpoint {
        //GET Endpoints
        case myContactsEndpoint(myID: Int)
        case eventListEndpoint
        case requestListEndpoint(myID: Int)
        
        //POST Endpoints
        case loginEndpoint(email: String, password: String)
        case registerAccountEndpoint(user: Person, password: String)
        case requestResponseEndpoint(myID: Int, sourcePersonID: Int, state: Request.State)
        case sendRequestEndpoint(myID: Int, personID: Int)
        case privacyEndpoint(myID: Int, sharePicture: Bool)
        case checkInEndpoint(myID: Int, eventID: Int)
        
        var description: String {
            switch self {
            case .myContactsEndpoint:
                return "/mycontacts"
            case .eventListEndpoint:
                return "/eventlist"
            case .requestListEndpoint:
                return "/requestlist"
            case .loginEndpoint:
                return "/login"
            case .registerAccountEndpoint:
                return "/registeraccount"
            case .requestResponseEndpoint:
                return "/requestresponse"
            case .sendRequestEndpoint:
                return "/sendrequest"
            case .privacyEndpoint:
                return "/privacy"
            case .checkInEndpoint:
                return "/checkin"
            }
        }
        
        var requestType: RequestType {
            switch self {
            case .myContactsEndpoint, .eventListEndpoint, .requestListEndpoint:
                return .get
            case .loginEndpoint, .registerAccountEndpoint, .requestResponseEndpoint, .sendRequestEndpoint, .privacyEndpoint, .checkInEndpoint:
                return .post
            }
        }
    }
    
    fileprivate static let session: URLSession = {
        return URLSession(configuration: .default)
    }()

    
    static func urlFor(_ endpoint: Endpoint) -> URL {
        let url = URL(string: baseURL + endpoint.description)
        return url!
    }
    
    internal static func contactAPIFor(endPoint: Endpoint, completion: @escaping (RequestResult) -> ()) {
        let url = urlFor(endPoint)
        let requestType = endPoint.requestType
        let jsonData: [String: Any]!
        
        switch endPoint {
        case let .myContactsEndpoint(myID):
            jsonData = ["myID" : myID]
        case .eventListEndpoint:
            jsonData = [:]
        case let .requestListEndpoint(myID):
            jsonData = ["myID" : myID]
        case let .loginEndpoint(email, password):
            jsonData = ["email": email, "password" : password]
        case let .registerAccountEndpoint(user, password):
            jsonData = user.jsonRepresntation
            jsonData["password"] = password
        case let .requestResponseEndpoint(myID, sourcePersonID, state):
            jsonData = ["myID": myID, "sourcePersonID": sourcePersonID, "state": state.rawValue]
        case let .sendRequestEndpoint(myID, personID):
            jsonData = ["myID": myID, "personID" : personID]
        case let .privacyEndpoint(myID, sharePicture):
            jsonData = ["myID": myID, "sharePicture": sharePicture]
        case let .checkInEndpoint(myID, eventID):
            jsonData = ["myID": myID, "eventID": eventID]
        }
        
        //TODO: Move the request to a separate function
        var request = URLRequest(url: url)
        let json = try! JSONSerialization.data(withJSONObject: jsonData, options: [])
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = requestType.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = json

        let task = session.dataTask(with: request) { (optionalData, optionalResponse, optionalError) in
            guard let response = optionalResponse,
            let httpResponse = response as? HTTPURLResponse else {
                print(optionalError.debugDescription)
                completion(.systemFailure(optionalError!))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                if let data = optionalData {
                    let objectFromData = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    completion(.success(objectFromData))
                }
            default:
                completion(.networkFailure(httpResponse))
            }
        }
        
        task.resume()

    }
  
}


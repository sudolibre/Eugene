//
//  PresenceAPI.swift
//  Presence
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

enum RequestResult {
    case success(Any)
    case networkFailure(HTTPURLResponse)
    case systemFailure(Error)
}


internal final class EugeneAPI {
    
    private static let baseURL = "https://paul-tiy-presence.herokuapp.com"
    
    enum RequestType: String {
        case get = "GET", post = "POST"
    }

    enum Endpoint {
        //GET Endpoints
        case eventListEndpoint
        
        //POST Endpoints
        case loginEndpoint(email: String, password: String)
        case registerAccountEndpoint(user: Person, password: String)
        case myContactsEndpoint(myEmail: String)
        case incomingRequestListEndpoint(myEmail: String)
        case outgoingRequestListEndpoint(myEmail: String)
        case getContactInfoEndpoint(userEmail: String)
        case eventAttendees(eventID: Int)
        case requestResponseEndpoint(myEmail: String, requestID: Int, accept: Bool)
        case sendRequestEndpoint(myEmail: String, personEmail: String)
        case privacyEndpoint(myEmail: String)
        case checkInEndpoint(myEmail: String, eventID: Int)
        
        var description: String {
            switch self {
            case .myContactsEndpoint:
                return "/get-user-contacts.json"
            case .eventListEndpoint:
                return "/get-open-events.json"
            case .eventAttendees:
                return "/get-event-attendees.json"
            case .incomingRequestListEndpoint:
                return "/user-incoming-requests.json"
            case .outgoingRequestListEndpoint:
                return "/user-outgoing-requests.json"
            case .getContactInfoEndpoint:
                return "/get-user-info.json"
            case .loginEndpoint:
                return "/user-login.json"
            case .registerAccountEndpoint:
                return "/user-registration.json"
            case .requestResponseEndpoint:
                return "/respond-to-request.json"
            case .sendRequestEndpoint:
                return "/send-request.json"
            case .privacyEndpoint:
                return "/toggle-photo-visible.json"
            case .checkInEndpoint:
                return "/user-event-signup.json"
            case .getContactInfoEndpoint:
                return "/get-user-info.json"
            }
        }
        
        var requestType: RequestType {
            switch self {
            case .eventListEndpoint:
                return .get
            case .myContactsEndpoint, .outgoingRequestListEndpoint, .incomingRequestListEndpoint, .loginEndpoint, .registerAccountEndpoint, .requestResponseEndpoint, .sendRequestEndpoint, .privacyEndpoint, .checkInEndpoint, .getContactInfoEndpoint, .eventAttendees:
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
        let jsonData: [String: Any]?
        
        
        switch endPoint {
        case let .myContactsEndpoint(myEmail):
            jsonData = ["email" : myEmail]
        case .eventListEndpoint:
            jsonData = nil
        case let .eventAttendees(eventID):
            jsonData = ["eventID": eventID]
        case let .incomingRequestListEndpoint(myEmail):
            jsonData = ["email" : myEmail]
        case let .outgoingRequestListEndpoint(myEmail):
            jsonData = ["email" : myEmail]
        case let .loginEndpoint(email, password):
            jsonData = ["email": email, "password" : password]
        case let .registerAccountEndpoint(user, password):
            jsonData = user.jsonRepresntation
            jsonData!["password"] = password
        case let .requestResponseEndpoint(myEmail, requestID, state):
            jsonData = ["email": myEmail, "requestID": requestID, "accept": state]
        case let .sendRequestEndpoint(myEmail, personEmail):
            jsonData = ["requesterEmail": myEmail, "requesteeEmail" : personEmail]
        case .privacyEndpoint:
            jsonData = nil
        case let .checkInEndpoint(myEmail, eventID):
            jsonData = ["email": myEmail, "eventID": eventID]
        case let .getContactInfoEndpoint(userEmail):
            jsonData = ["email": userEmail]
        }
        
        //TODO: Move the request to a separate function
        var request = URLRequest(url: url)
        if let _jsonData = jsonData {
            let json = try! JSONSerialization.data(withJSONObject: _jsonData, options: [])
            request.httpBody = json
        }
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = requestType.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        print(jsonData)

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
                    let objectFromData = try! JSONSerialization.jsonObject(with: data, options: [])
                    completion(.success(objectFromData))
                }
            default:
                completion(.networkFailure(httpResponse))
            }
        }
        task.resume()

    }
  
}


//
//  Request.swift
//  Presence
//
//  Created by Jonathon Day on 1/25/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class Request {
    
    enum State: String {
        case accepted = "accepted",
        rejected = "rejected",
        expired = "expired",
        pending = "pending"
    }
    
    var jsonRepresentation: [String: Any] {
        let rep: [String: Any] = [
            "person" : person.jsonRepresntation,
            "state" : state.rawValue,
            "date" : date.timeIntervalSince1970
        ]
        
        return rep
    }
    
    var person: Person
    var state: State
    var date: Date
    
    init(person: Person, state: State) {
        self.person = person
        self.state = state
        self.date = Date()
    }
    
    init(jsonRep: [String: Any]) {
        let person = Person(jsonRep: jsonRep["person"] as! [String : Any])
        self.person = person
        let dateInterval = jsonRep["requestTime"] as! TimeInterval
        self.date = Date(timeIntervalSince1970: dateInterval)
        let stateString = jsonRep["state"] as! String
        self.state =  {
            switch stateString {
                case "accepted":
                return .accepted
                case "rejected":
                return .rejected
                case "expired":
                return .expired
                case "pending":
                return .pending
            default:
                fatalError("unexpected string \"\(stateString)\" for the state of a request")
            }
        }()
    }
}

extension Request: Equatable {
    static func ==(_ lhs: Request, _ rhs: Request) -> Bool {
        return lhs.person == rhs.person && lhs.state == rhs.state
    }
    
}

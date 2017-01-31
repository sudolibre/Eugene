//
//  Request.swift
//  Presence
//
//  Created by Jonathon Day on 1/25/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class Request {
    
    var ID: Int
    var requesterEmail: String
    var requesteeEmail: String
    var state: State
    var recentRequestTime: Date
    
    enum State: String {
        case friends = "FRIENDS",
        rejected = "REJECTED",
        requested = "REQUESTED",
        blocked = "BLOCKED"
    }
    
    func returnDirection(currentUserEmail: String) -> ListChoice? {
        switch currentUserEmail {
        case requesteeEmail:
            return .incoming
        case requesterEmail:
            return .outgoing
        default:
            return nil
        }
    }
    
//    var jsonRepresentation: [String: Any] {
//        var rep: [String: Any] = [
//            "person" : person.jsonRepresntation,
//            "status" : state.rawValue,
//            "originalRequestTime" : originalRequestDate.timeIntervalSince1970,
//            "stale": stale,
//            "id" : ID
//        ]
//        
//        if let _refreshRequestDate = refreshRequestDate {
//            rep["refreshRequestTime"] = _refreshRequestDate.timeIntervalSince1970
//        }
//        
//        
//        return rep
//    }
    
   
    
    
//    init(person: Person, state: State) {
//        self.person = person
//        self.state = state
//        self.originalRequestDate = Date()
//        self.refreshRequestDate = Date()
//        ID = 99
//        stale = false
//    }
    
    init(jsonRep: [String: Any]) {
        let recentRequestTimeInterval = jsonRep["recentRequestTime"] as! TimeInterval
        self.recentRequestTime = Date(timeIntervalSince1970: recentRequestTimeInterval)
        let stateString = jsonRep["status"] as! String
        self.state = State(rawValue: stateString)!
        self.ID = jsonRep["id"] as! Int
        self.requesteeEmail = jsonRep["requesteeEmail"] as! String
        self.requesterEmail = jsonRep["requesterEmail"] as! String
    }
}

extension Request: Equatable {
    static func ==(_ lhs: Request, _ rhs: Request) -> Bool {
        return lhs.requesterEmail == rhs.requesterEmail && lhs.requesteeEmail == rhs.requesteeEmail
    }
    
}

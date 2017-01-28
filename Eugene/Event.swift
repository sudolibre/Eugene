//
//  Event.swift
//  Presence
//
//  Created by Jonathon Day on 1/25/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import Foundation

class Event {
    var name: String
    var date: Date
    var location: String
    var address: String
    var people: [Person]
    
    var jsonRepresentation: [String: Any] {
        var rep: [String: Any] = [
            "name": name,
            "location": location,
            "address": address
        ]
        let jsonDate = date.timeIntervalSince1970
        rep["date"] = jsonDate
        let jsonPeople = people.map({$0.jsonRepresntation})
        rep["people"] = jsonPeople

        return rep
    }
    
    init(name: String, date: Date, location: String, address: String, people: [Person]) {
        self.name = name
        self.date = date
        self.location = location
        self.address = address
        self.people = people
    }
    
    init(jsonRep: [String: Any]) {
        self.name = jsonRep["name"] as! String
        self.location = jsonRep["location"] as! String
        self.address = jsonRep["address"] as! String
        let date = Date(timeIntervalSince1970: jsonRep["date"] as! Double)
        self.date = date
        let jsonPeople = jsonRep["people"] as! [[String: Any]]
        let people = jsonPeople.map({Person(jsonRep: $0)})
        self.people = people
    }
}

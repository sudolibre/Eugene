//
//  Person.swift
//  Presence
//
//  Created by Jonathon Day on 1/25/17.
//  Copyright © 2017 dayj. All rights reserved.
//
import UIKit
import Foundation

//TODO: consider making ID on event and person optional

class Person {
    var name: PersonNameComponents
    var company: String
    var picture: UIImage?
    var sharePicture: Bool?
    var position: String?
    var email: String?
    var ID: Int?
    
    var jsonRepresntation: [String: Any] {
        var rep: [String: Any] = [
            "firstName" : name.givenName!,
            "lastName" : name.familyName!,
            "company": company,
            "photoVisible": sharePicture,
        ]
        
        if let _picture = picture {
            rep["imageString"] = "placeholder picture string" //UIImagePNGRepresentation(_picture)!.base64EncodedString()
        }

        if let _position = position{
            rep["position"] = _position
        }
        if let _email = email {
        rep["email"] = _email
        }

        return rep
    }
    
    init(givenName: String, familyName: String, company: String, picture: UIImage? = nil, sharePicture: Bool, ID: Int? = nil, position: String? = nil, email: String? = nil) {
        var name = PersonNameComponents()
        name.familyName = familyName
        name.givenName = givenName
        self.name = name
        self.company = company
        self.picture = picture
        self.sharePicture = sharePicture
        self.position = position
        self.email = email
        self.ID = ID
    }
    
    init(jsonRep: [String: Any]) {
        var name = PersonNameComponents()
        name.givenName = (jsonRep["firstName"] as! String)
        name.familyName = (jsonRep["lastName"] as! String)
        self.name = name
        self.company = jsonRep["company"] as! String
        if let ID = jsonRep["ID"] as? Int {
            self.ID = ID
        }
        if let pictureString = jsonRep["imageString"] as? String,
            let pictureData = Data.init(base64Encoded: pictureString, options: .ignoreUnknownCharacters) {
            picture = UIImage(data: pictureData)
        }
        if let photoVisible = jsonRep["photoVisible"] as? Bool {
            self.sharePicture = photoVisible
        }
        if let position = jsonRep["position"] as? String {
            self.position = position
        }
        if let email = jsonRep["email"] as? String {
            self.email = email
        }

    }
}

extension Person: Equatable {
    static func ==(_ lhs: Person, _ rhs: Person) -> Bool {
    return lhs.name == rhs.name && lhs.company == rhs.company && lhs.sharePicture == rhs.sharePicture && lhs.position == rhs.position && lhs.email == rhs.email
        
        //&& lhs.picture == rhs.picture
    }
}


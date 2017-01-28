//
//  Person.swift
//  Presence
//
//  Created by Jonathon Day on 1/25/17.
//  Copyright © 2017 dayj. All rights reserved.
//
import UIKit
import Foundation

class Person {
    var name: PersonNameComponents
    var company: String
    var picture: UIImage?
    var sharePicture: Bool
    var position: String?
    var email: String?
    var ID: Int?
    
    var jsonRepresntation: [String: Any] {
        var rep: [String: Any] = [
            "givenName" : name.givenName!,
            "familyName" : name.familyName!,
            "ID": ID,
            "company": company,
            //"picture" : UIImagePNGRepresentation(picture)!.base64EncodedString() ,
            "sharePicture": sharePicture,
        ]
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
        //self.picture = picture
        self.sharePicture = sharePicture
        self.position = position
        self.email = email
    }
    
    init(jsonRep: [String: Any]) {
        var name = PersonNameComponents()
        name.givenName = (jsonRep["givenName"] as! String)
        name.familyName = (jsonRep["familyName"] as! String)
        self.name = name
        self.company = jsonRep["company"] as! String
        if let ID = jsonRep["ID"] as? Int {
            self.ID = ID
        }
        //let pictureData = Data.init(base64Encoded: jsonRep["picture"] as! String, options: .ignoreUnknownCharacters)!
        //picture = UIImage(data: pictureData)!
        self.sharePicture = jsonRep["sharePicture"] as! Bool
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


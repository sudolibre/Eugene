//
//  EugeneTests.swift
//  EugeneTests
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import XCTest
@testable import Eugene

class EugeneTests: XCTestCase {
    
    func testPersonJSONRoundtrip() {
        let picture = UIImage(named: "eugeneSmall")!
        let person = Person(givenName: "John", familyName: "Appleseed", company: "The Store", picture: picture, sharePicture: true, ID: 9675309, position: "individual contributer", email: "asdf@gahoo.com")
        let jsonPerson = try! JSONSerialization.data(withJSONObject:person.jsonRepresntation, options: [])
        let foundationObjectFromJson = try! JSONSerialization.jsonObject(with: jsonPerson, options: [])
        let revivedPerson = Person(jsonRep: foundationObjectFromJson as! [String : Any])
        XCTAssertTrue(
            person.name == revivedPerson.name &&
                person.company == revivedPerson.company &&
                //person.picture == revivedPerson.picture &&
                person.sharePicture == revivedPerson.sharePicture &&
                person.position == revivedPerson.position &&
                person.email == revivedPerson.email
        )
    }
    
    func testEventJSONRoundtrip() {
        let people = [
            Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309),
            Person(givenName: "Amy", familyName: "Robertson", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 12345),
            Person(givenName: "Adrian", familyName: "McDaniel", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 10203040),
            ]
        let event = Event(name: "iOS Crash Course", date: Date(), location: "TIY", address: "Near 5 Points", people: people)
        let eventAsJSON = try! JSONSerialization.data(withJSONObject: event.jsonRepresentation, options: [])
        let eventAsFoundationObject = try! JSONSerialization.jsonObject(with: eventAsJSON, options: []) as! [String: Any]
        let revivedEvent = Event(jsonRep: eventAsFoundationObject)
        
        XCTAssertTrue(
            zip(event.people, revivedEvent.people).reduce(true) { (doesMatch, personPair) -> Bool in
                if doesMatch == false {
                    return false
                }
                return personPair.0.name == personPair.1.name &&
                    personPair.0.company == personPair.1.company &&
                    //personPair.0.picture == personPair.1.picture &&
                    personPair.0.sharePicture == personPair.1.sharePicture &&
                    personPair.0.position == personPair.1.position &&
                    personPair.0.email == personPair.1.email
        })
    }
    
    func testRequestJSONRoundtrip() {
        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
        let request = Request(person: person, state: .accepted)
        let jsonRequest = try! JSONSerialization.data(withJSONObject: request.jsonRepresentation, options: [])
        let jsonFoundationObject = try! JSONSerialization.jsonObject(with: jsonRequest, options: []) as! [String: Any]
        let revivedRequest = Request(jsonRep: jsonFoundationObject)
        
        XCTAssertTrue(request == revivedRequest)
    }
    
    
    func testEugeneAPIURL() {
        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
        let person2 = Person(givenName: "Amy", familyName: "Robertson", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 90210)
        let resultForLogin = EugeneAPI.urlFor(.loginEndpoint(email: "test@gmail.com", password: "password"))
        let resultForRegister = EugeneAPI.urlFor(.registerAccountEndpoint(user: person, password: "password"))
        let resultForRequestResponse = EugeneAPI.urlFor(.requestResponseEndpoint(myEmail: person.ID!, sourcePersonID: person2.ID!, state: .accepted))
        let resultForSendRequest = EugeneAPI.urlFor(.sendRequestEndpoint(myEmail: person.ID!, personID: person2.ID!))
        let resultForPrivacy = EugeneAPI.urlFor(.privacyEndpoint(myEmail: person.ID!, sharePicture: true))
        let resultForCheckIn = EugeneAPI.urlFor(.checkInEndpoint(myEmail: person.ID!, eventID: 8675309))
        let resultForMyContacts = EugeneAPI.urlFor(.myContactsEndpoint(myEmail: person.ID!))
        let resultForEventList = EugeneAPI.urlFor(.eventListEndpoint)
        let resultForRequestList = EugeneAPI.urlFor(.requestListEndpoint(myEmail: person.ID!))
        
        let expectedForMyContacts = URL(string: "https://eugene-tiy.herokuapp.com/mycontacts")
        let expectedForEventList = URL(string: "https://eugene-tiy.herokuapp.com/eventlist")
        let expectedForRequestList = URL(string: "https://eugene-tiy.herokuapp.com/requestlist")
        let expectedForLogin = URL(string: "https://eugene-tiy.herokuapp.com/login")
        let expectedForRegister = URL(string: "https://eugene-tiy.herokuapp.com/registeraccount")
        let expectedForRequestResponse = URL(string: "https://eugene-tiy.herokuapp.com/requestresponse")
        let expectedForSendRequest = URL(string: "https://eugene-tiy.herokuapp.com/sendrequest")
        let expectedForPrivacy = URL(string: "https://eugene-tiy.herokuapp.com/privacy")
        let expectedForCheckIn = URL(string: "https://eugene-tiy.herokuapp.com/checkin")
        
        XCTAssertTrue(resultForLogin == expectedForLogin)
        XCTAssertTrue(resultForRegister == expectedForRegister)
        XCTAssertTrue(resultForRequestResponse == expectedForRequestResponse)
        XCTAssertTrue(resultForSendRequest == expectedForSendRequest)
        XCTAssertTrue(resultForPrivacy == expectedForPrivacy)
        XCTAssertTrue(resultForCheckIn == expectedForCheckIn)
        XCTAssertTrue(resultForMyContacts == expectedForMyContacts)
        XCTAssertTrue(resultForEventList == expectedForEventList)
        XCTAssertTrue(resultForRequestList == expectedForRequestList)
    }
    
    func testEndpointLogin() {
        let exp = expectation(description: "login succeeded")
        EugeneAPI.contactAPIFor(endPoint: .loginEndpoint(email: "joe@gmail.com", password: "password")) { (result) in
            if case .success = result {
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 30.0)
    }
    
    func testEndpointRegister() {
        let randomNumber = arc4random_uniform(1000000000)
        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: nil, sharePicture: false, ID: nil, position: "Instructor", email: "test\(randomNumber)@gmail.com")
        let exp = expectation(description: "register succeeded")
        EugeneAPI.contactAPIFor(endPoint: .registerAccountEndpoint(user: person, password: "password")) { (result) in
            if case .success = result {
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 30.0)
    }
//    
//    func testEndpointRequestList() {
//        let exp = expectation(description: "register list retrieved succeeded")
//        EugeneAPI.contactAPIFor(endPoint: .requestListEndpoint(myEmail: 8675309)) { (result) in
//            if case .success = result {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 30.0)
//    }
//    
//    func testEndpointMyContactsList() {
//        let exp = expectation(description: "contact list retrieval succeeded")
//        EugeneAPI.contactAPIFor(endPoint: .myContactsEndpoint(myEmail: 8675309)) { (result) in
//            if case .success = result {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 30.0)
//    }
//    
//    func testEndpointEventList() {
//        let exp = expectation(description: "event list retrieved succeeded")
//        EugeneAPI.contactAPIFor(endPoint: .eventListEndpoint) { (result) in
//            if case .success = result {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 30.0)
//    }
//    
//    func testEndpointRequestResponse() {
//        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
//        let person2 = Person(givenName: "Amy", familyName: "Robertson", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 90210)
//
//        let exp = expectation(description: "request responded to successfully")
//        EugeneAPI.contactAPIFor(endPoint: .requestResponseEndpoint(myEmail: person.ID!, sourcePersonID: person2.ID!, state: .rejected)) { (result) in
//            if case .success = result {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 30.0)
//    }
//    
//    func testEndpointSendResponse() {
//        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
//        let person2 = Person(givenName: "Amy", familyName: "Robertson", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 90210)
//        
//        let exp = expectation(description: "request sent successfully")
//        EugeneAPI.contactAPIFor(endPoint: .sendRequestEndpoint(myEmail: person.ID!, personID: person2.ID!)) { (result) in
//            if case .success = result {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 30.0)
//    }
//    
//    func testEndpointPrivacy() {
//        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
//        let exp = expectation(description: "privacy change succeeded")
//        EugeneAPI.contactAPIFor(endPoint: .privacyEndpoint(myEmail: person.ID!, sharePicture: true)) { (result) in
//            if case .success = result {
//                exp.fulfill()
//            }
//        }
//        waitForExpectations(timeout: 30.0)
//    }
}

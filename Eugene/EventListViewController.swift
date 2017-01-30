//
//  FirstViewController.swift
//  Eugene
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class EventListViewController: UITableViewController {
    
    var dataSource: EventListDataSource!
    var currentUserID: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //TODO: REMOVE ME AFTER Implementation
        dataSource = EventListDataSource()
        currentUserID = 99
        //dataSource.fetchlist()
        
        
        
        
        
        
        tableView.dataSource = dataSource
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "eventDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let eventDetailVC = segue.destination as! EventDetailViewController
        //TODO: add subscript to datasource
        eventDetailVC.event = dataSource.events[tableView.indexPathForSelectedRow!.row]
        eventDetailVC.currentUserID = currentUserID
    }


}

class EventListDataSource: NSObject, UITableViewDataSource {
    var events: [Event] = []
    
    internal func fetchlist() {
        EugeneAPI.contactAPIFor(endPoint: .eventListEndpoint) { (result) in
            switch result {
            case .success(let data):
                let eventsDictionaries = data.first!.value as! [[String: Any]]
                self.events = eventsDictionaries.map({Event(jsonRep: $0)}).sorted(by: {$0.1.date > $0.0.date })
            case .networkFailure(let response):
                fatalError(response.description)
            case .systemFailure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    //MARK: Tableview Datasource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")!
        let event = events[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateDescription = formatter.string(from: event.date)
        cell.textLabel!.text = event.name
        cell.detailTextLabel!.text = "\(dateDescription) @ \(event.location)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override init() {
        super.init()
        //fetchlist()
        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
        let person2 = Person(givenName: "Amy", familyName: "Robertson", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 90210)
        let event = Event(name: "Crash course", date: Date(), location: "TIY", address: "MLK Somewhere", people: [person, person2], ID: 5)
        events = Array(repeating: event , count: 50)
    }
    
    
}


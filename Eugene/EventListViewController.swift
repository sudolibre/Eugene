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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //TODO: REMOVE ME AFTER Implementation
        dataSource = EventListDataSource()
        
        
        
        
        
        
        
        tableView.dataSource = dataSource
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view appear")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("anything")
    }


}

class EventListDataSource: NSObject, UITableViewDataSource {
    var events: [Event] = []
    
    internal func fetchlist() {
        EugeneAPI.contactAPIFor(endPoint: .eventListEndpoint) { (result) in
            switch result {
            case .success(let data):
                let eventsDictionaries = data.first!.value as! [[String: Any]]
                self.events = eventsDictionaries.map({Event(jsonRep: $0)})
            case .networkFailure(let response):
                fatalError(response.description)
            case .systemFailure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    internal func registerCellFor(_ tableview: UITableView) {
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "eventCell")
    }
    
    
    //MARK: Tableview Datasource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell")!
        let event = events[indexPath.row]
        
        cell.textLabel!.text = event.name
        cell.detailTextLabel!.text = "\(event.date) @ \(event.location)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override init() {
        super.init()
        //fetchlist()
        let event = Event(name: "Crash course", date: Date(), location: "TIY", address: "MLK Somewhere", people: [])
        events = Array(repeating: event , count: 50)
    }
    
    
}


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
    var currentUserEmail: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.reloadData()
        dataSource.fetchlist(tableView)
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
        eventDetailVC.currentUserEmail = currentUserEmail
    }


}

class EventListDataSource: NSObject, UITableViewDataSource {
    var events: [Event] = []
    
    internal func fetchlist(_ tableView: UITableView) {
        EugeneAPI.contactAPIFor(endPoint: .eventListEndpoint) { (result) in
            switch result {
            case .success(let data):
                let dictionary = data as! [[String: Any]]
                let events = dictionary.map({Event(jsonRep: $0)}).sorted(by: {$0.1.date > $0.0.date })
                print(events)
                self.events = events
                tableView.reloadData()
            case .networkFailure(let response):
                print(response.description)
            case .systemFailure(let error):
                print(error.localizedDescription)
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
    }
    
    
}


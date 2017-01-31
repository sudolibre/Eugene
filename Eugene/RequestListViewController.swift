//
//  RequestTableViewController.swift
//  Eugene
//
//  Created by Jonathon Day on 1/28/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class RequestListViewController: UITableViewController {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var dataSource: RequestListDataSource!
    var currentUserEmail: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.dataSource = dataSource


        
        segmentedControl.addTarget(self, action: #selector(switchTableViews(_:)), for: .valueChanged)
    }
    
    func switchTableViews(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dataSource.activeList = .incoming
        case 1:
            dataSource.activeList = .outgoing
        default:
            fatalError()
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "contactDetail", sender: nil)
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contactDetailVC = segue.destination as! ContactDetailViewController
        let selectedRequest = dataSource.requestAt(index: tableView.indexPathForSelectedRow!.row)
        contactDetailVC.contact = selectedRequest.person
        contactDetailVC.request = selectedRequest
        contactDetailVC.direction = dataSource.activeList
    }

}

class RequestListDataSource: NSObject, UITableViewDataSource {
    var incomingRequests: [Request]
    var outgoingRequests: [Request]
    var activeList: ListChoice = .incoming
    let reuseIdentifier = "requestCell"
    var currentUserEmail: String
    
    internal func requestAt(index: Int) -> Request {
        switch activeList {
        case .incoming:
            return incomingRequests[index]
        case.outgoing:
            return outgoingRequests[index]
        }
    }
    
//    (result) in
//    switch result {
//    case .success(let data):
//    let incomingRequestsDictionaries = data["incoming"] as! [[String: Any]]
//    let outgoingRequestsDictionaries = data["outgoing"] as! [[String: Any]]
//    self.incomingRequests = incomingRequestsDictionaries.map({Request(jsonRep: $0)}).sorted(by: {$0.1.date > $0.0.date})
//    self.outgoingRequests = outgoingRequestsDictionaries.map({Request(jsonRep: $0)}).sorted(by: {$0.1.date > $0.0.date})
//    case .networkFailure(let response):
//    fatalError(response.description)
//    case .systemFailure(let error):
//    fatalError(error.localizedDescription)
//    }

    
    internal func fetchlist() {
    EugeneAPI.contactAPIFor(endPoint: .incomingRequestListEndpoint(myEmail: currentUserEmail)) { (result) in
        switch result {
        case let .success(data):
            let dictionary = data as! [[String: Any]]
            let requests = dictionary.map({Request(jsonRep: $0)})
            self.incomingRequests = requests
        case .networkFailure(let response):
            fatalError(response.description)
        case .systemFailure(let error):
            fatalError(error.localizedDescription)
        }
        }

    }
    
    
    //MARK: Tableview Datasource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        let request: Request!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        switch activeList {
        case .incoming:
            request = incomingRequests[indexPath.row]
        case .outgoing:
            request = outgoingRequests[indexPath.row]
        }
        
        var fontColor = UIColor.black
        var accessoryType: UITableViewCellAccessoryType = .disclosureIndicator

        if request.state == .friends {
        accessoryType = .checkmark
        }
        
        if request.stale == true {
          fontColor = UIColor.lightGray
        }

        cell.accessoryType = accessoryType
        cell.detailTextLabel!.textColor = fontColor
        cell.textLabel!.textColor = fontColor
        cell.textLabel!.text = PersonNameComponentsFormatter.localizedString(from: request.person.name, style: .default, options: [])
        if let refreshDate = request.refreshRequestDate {
        cell.detailTextLabel!.text = dateFormatter.string(from: refreshDate)
        } else {
            cell.detailTextLabel!.text = dateFormatter.string(from: request.originalRequestDate)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeList {
        case .incoming:
            return incomingRequests.count
        case .outgoing:
            return outgoingRequests.count
        }
    }
    
    init(forUserID userEmail: String, incomingRequests: [Request]? = nil, outgoingRequests: [Request]? = nil) {
        self.currentUserEmail = userEmail
        if let irequests = incomingRequests,
            let orequests = outgoingRequests {
            self.incomingRequests = irequests
            self.outgoingRequests = orequests
            super.init()
        } else {
            self.incomingRequests = []
            self.outgoingRequests = []
            super.init()
            fetchlist()
        }
    }
    
}

enum ListChoice {
    case incoming
    case outgoing
}

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
    var currentUserID: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserID = 66
        
        
        //TODO: REMOVE AFTER IMPLEMENTATION
        let person = Person(givenName: "TJ", familyName: "Usomething", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: false, ID: 8675309)
        let person2 = Person(givenName: "Amy", familyName: "Robertson", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 90210)
        let person3 = Person(givenName: "Adrian", familyName: "McDaniel", company: "TIY", picture: UIImage(named: "eugeneSmall")!, sharePicture: true, ID: 10203040)


        let incoming = [Request(person: person, state: .expired), Request(person: person2, state: .accepted), Request(person: person3, state: .pending)]
        let outgoing = [Request(person: person3, state: .accepted), Request(person: person, state: .expired), Request(person: person2, state: .pending)]
        self.dataSource = RequestListDataSource(forUserID: currentUserID, incomingRequests: incoming, outgoingRequests: outgoing)
        tableView.dataSource = dataSource

        // REMOVE ME ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        
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
        switch dataSource.activeList {
        case .incoming:
            contactDetailVC.contactRequestedConnection = true
        case .outgoing:
            contactDetailVC.contactRequestExpired = selectedRequest.state == .expired
        }
    }


}

class RequestListDataSource: NSObject, UITableViewDataSource {
    var incomingRequests: [Request]
    var outgoingRequests: [Request]
    var activeList: ListChoice = .incoming
    let reuseIdentifier = "requestCell"
    var currentUserID: Int
    
    enum ListChoice {
        case incoming
        case outgoing
    }
    
    internal func requestAt(index: Int) -> Request {
        switch activeList {
        case .incoming:
            return incomingRequests[index]
        case.outgoing:
            return outgoingRequests[index]
        }
    }
    
    internal func fetchlist() {
        EugeneAPI.contactAPIFor(endPoint: .requestListEndpoint(myID: currentUserID)) { (result) in
            switch result {
            case .success(let data):
                let incomingRequestsDictionaries = data["incoming"] as! [[String: Any]]
                let outgoingRequestsDictionaries = data["outgoing"] as! [[String: Any]]
                self.incomingRequests = incomingRequestsDictionaries.map({Request(jsonRep: $0)}).sorted(by: {$0.1.date > $0.0.date})
                self.outgoingRequests = outgoingRequestsDictionaries.map({Request(jsonRep: $0)}).sorted(by: {$0.1.date > $0.0.date})
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

        switch request.state {
        case .accepted:
            accessoryType = .checkmark
        case .pending:
            break
        case .expired:
            fontColor = UIColor.lightGray
        case .rejected:
            fatalError("rejected requests should not appear in the table")
        }
        
        cell.accessoryType = accessoryType
        cell.detailTextLabel!.textColor = fontColor
        cell.textLabel!.textColor = fontColor
        cell.textLabel!.text = PersonNameComponentsFormatter.localizedString(from: request.person.name, style: .default, options: [])
        cell.detailTextLabel!.text = dateFormatter.string(from: request.date)
        
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
    
    init(forUserID userID: Int, incomingRequests: [Request]? = nil, outgoingRequests: [Request]? = nil) {
        self.currentUserID = userID
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

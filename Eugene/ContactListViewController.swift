//
//  SecondViewController.swift
//  Eugene
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class ContactListViewController: UITableViewController {
    
    var dataSource: ContactListDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "contactDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contactDetailVC = segue.destination as! ContactDetailViewController
        contactDetailVC.contact = dataSource.contacts[tableView.indexPathForSelectedRow!.row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class ContactListDataSource: NSObject, UITableViewDataSource {
    var contacts: [Person]
    let reuseIdentifier = "contactCell"
    var currentUserEmail: String

    
    internal func fetchlist() {
        EugeneAPI.contactAPIFor(endPoint: .myContactsEndpoint(myEmail: currentUserEmail)) { (result) in
            switch result {
            case .success(let data):
                let dictionary = data as! [[String: Any]]
                let contacts = dictionary.map({Person(jsonRep: $0)})
                self.contacts = contacts
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
        let contact = contacts[indexPath.row]
        
        cell.textLabel!.text = PersonNameComponentsFormatter.localizedString(from: contact.name, style: .default, options: [])
        cell.detailTextLabel!.text = contact.company
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    init(forUserID userEmail: String, contacts: [Person]? = nil) {
        self.currentUserEmail = userEmail
        if let unrwappedContacts = contacts {
            self.contacts = unrwappedContacts
            super.init()
        } else {
            self.contacts = []
            super.init()
            fetchlist()
        }
    }

}


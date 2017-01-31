//
//  EventDetailViewController.swift
//  Eugene)
//
//  Created by Jonathon Day on 1/28/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    var event: Event!
    var attendees: [Person]?
    var currentUserEmail: String!
    
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var locationLabel : UILabel!
    @IBOutlet var addressLabel : UILabel!
    @IBOutlet var peopleLabel : UILabel!
    @IBOutlet var checkInButton: UIButton!
    @IBOutlet var viewAttendeesButton: UIButton!
    
    @IBAction func viewAttendeesTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "contactList", sender: nil)
    }
    
    @IBAction func checkInTapped(_ sender: UIButton) {
        EugeneAPI.contactAPIFor(endPoint: .checkInEndpoint(myEmail: currentUserEmail, eventID: event.ID!)) { [weak self] (result) in
            switch result {
            case .success:
                self?.userCheckedIn()
            case .networkFailure(let response):
                if response.statusCode == 401 {
                    let ac = UIAlertController(title: "Login Failed", message: "Email address or password is incorrect. Please try again or register a new account.", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                    ac.addAction(dismissAction)
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                        
                    }
                } else {
                    let ac = UIAlertController(title: "Login Failed", message: "An unexpected network error occured. Please try again or register a new account. (Code: \(response.statusCode)", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                    ac.addAction(dismissAction)
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                        
                    }
                }
            case .systemFailure(let error):
                fatalError("A system error has occured: \(error.localizedDescription)")
            }

            }
        }
    
    func userCheckedIn() {
        checkInButton.isHidden = true
        viewAttendeesButton.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAttendeesButton.adjustsImageWhenDisabled = true
        viewAttendeesButton.isEnabled = false
        //viewAttendeesButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        nameLabel.text = event.name
        locationLabel.text = event.location
        addressLabel.text = event.address
        peopleLabel.text = "checking for attendees..."
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateDescription = dateFormatter.string(from: event.date)
        dateLabel.text = dateDescription
        
        EugeneAPI.contactAPIFor(endPoint: .eventAttendees(eventID: event.ID!)) { (result) in
            switch result {
            case .success(let data):
                let attendeeData = data as! [[String: Any]]
                self.attendees = attendeeData.map({Person(jsonRep: $0)})
                self.peopleLabel.text = "\(self.attendees!.count) others checked in"
                self.viewAttendeesButton.isEnabled = true
            case.networkFailure(let error):
                fatalError(error.debugDescription)
            case .systemFailure(let error):
                fatalError(error.localizedDescription)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let contactListVC = segue.destination as! ContactListViewController
        let dataSource = ContactListDataSource(forUserID: currentUserEmail, contacts: attendees)
        contactListVC.dataSource = dataSource
    }


}

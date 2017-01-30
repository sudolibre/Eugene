//
//  ContactDetailViewController.swift
//  Eugene
//
//  Created by Jonathon Day on 1/28/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    var contact: Person!
    var contactRequestedConnection: Bool = false
    var contactRequestExpired: Bool = false
    var currentUserID: Int!
    
    @IBOutlet var rejectButton: UIButton!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var positionLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var requestButton: UIButton!
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        EugeneAPI.contactAPIFor(endPoint: .requestResponseEndpoint(myID: currentUserID, sourcePersonID: contact.ID!, state: .rejected)) { [weak self] (result) in
            switch result {
            case .success:
                print("reject succeeded")
            case .networkFailure(let response):
                    let ac = UIAlertController(title: "Login Failed", message: "An unexpected network error occured. Please try again or register a new account. (Code: \(response.statusCode)", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                    ac.addAction(dismissAction)
                    DispatchQueue.main.async {
                        self?.present(ac, animated: true)
                        
                    }
            case .systemFailure(let error):
                fatalError("A system error has occured: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        EugeneAPI.contactAPIFor(endPoint: .requestResponseEndpoint(myID: currentUserID, sourcePersonID: contact.ID!, state: .accepted)) { [weak self] (result) in
            switch result {
            case .success:
                print("accept succeeded")
            case .networkFailure(let response):
                let ac = UIAlertController(title: "Login Failed", message: "An unexpected network error occured. Please try again or register a new account. (Code: \(response.statusCode)", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                ac.addAction(dismissAction)
                DispatchQueue.main.async {
                    self?.present(ac, animated: true)
                    
                }
            case .systemFailure(let error):
                fatalError("A system error has occured: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func requestTapped(_ sender: UIButton) {
        EugeneAPI.contactAPIFor(endPoint: .sendRequestEndpoint(myID: currentUserID, personID: contact.ID!)) { [weak self] (result) in
            switch result {
            case .success:
                print("request sent!")
            case .networkFailure(let response):
                let ac = UIAlertController(title: "Login Failed", message: "An unexpected network error occured. Please try again or register a new account. (Code: \(response.statusCode)", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                ac.addAction(dismissAction)
                DispatchQueue.main.async {
                    self?.present(ac, animated: true)
                    
                }
            case .systemFailure(let error):
                fatalError("A system error has occured: \(error.localizedDescription)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        currentUserID = 44
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switch (contact.email, contactRequestedConnection, contactRequestExpired) {
        case (_, _, true):
            requestButton.setTitle("Resend Request", for: .normal)
        case (_, true, _):
            acceptButton.isHidden = false
            acceptButton.isEnabled = true
            rejectButton.isHidden = false
            rejectButton.isEnabled = true
            fallthrough
        case (nil, _, _):
            //requestButton.isHidden = true
            //requestButton.isEnabled = false
            emailLabel.text = "🔒"
            positionLabel.text = "🔒"
        default:
            break
        }
        
        nameLabel.text = PersonNameComponentsFormatter.localizedString(from: contact.name, style: .default, options: [])
        companyLabel.text = contact.company
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

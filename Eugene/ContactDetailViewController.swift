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
    var request: Request?
    var currentUserEmail: String!
    var direction: ListChoice?
    
    @IBOutlet var rejectButton: UIButton!
    @IBOutlet var acceptButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var positionLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var requestButton: UIButton!
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        EugeneAPI.contactAPIFor(endPoint: .requestResponseEndpoint(myEmail: currentUserEmail, requestID: request!.ID, accept: false)) { [weak self] (result) in
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
        EugeneAPI.contactAPIFor(endPoint: .requestResponseEndpoint(myEmail: currentUserEmail, requestID: request!.ID, accept: true)) { [weak self] (result) in
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
        EugeneAPI.contactAPIFor(endPoint: .sendRequestEndpoint(myEmail: currentUserEmail, personEmail: contact.email!)) { [weak self] (result) in
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
//        switch (contact.email, request) {
//        case (_, _, true):
//            requestButton.setTitle("Resend Request", for: .normal)
//        case (_, true, _):
//            acceptButton.isHidden = false
//            acceptButton.isEnabled = true
//            rejectButton.isHidden = false
//            rejectButton.isEnabled = true
//            fallthrough
//        case (nil, _, _):
//            //requestButton.isHidden = true
//            //requestButton.isEnabled = false
//            emailLabel.text = "🔒"
//            positionLabel.text = "🔒"
//        default:
//            break
//        }
        
        nameLabel.text = PersonNameComponentsFormatter.localizedString(from: contact.name, style: .default, options: [])
        companyLabel.text = contact.company
        
        EugeneAPI.contactAPIFor(endPoint: .getContactInfoEndpoint(userEmail: contact.email!)) { (result) in
            switch result {
            case .success(let data):
                let dictionary = data as! [String: Any]
                let incomingRequests = (dictionary["incomingRequests"] as! [[String: Any]]).map({Request(jsonRep: $0)})
                let outgoingRequests = (dictionary["incomingRequests"] as! [[String: Any]]).map({Request(jsonRep: $0)})
                
                if incomingRequests.contains(where: { (request) -> Bool in
                    if let direction = request.returnDirection(currentUserEmail: self.currentUserEmail) {
                        return direction == .outgoing
                    } else {
                        return false
                    }
                })
                    {
                    self.direction = .outgoing
                }
                if outgoingRequests.contains(where: { (request) -> Bool in
                    if let direction = request.returnDirection(currentUserEmail: self.currentUserEmail) {
                        return direction == .incoming
                    } else {
                        return false
                    }
                })
                {
                    self.direction = .incoming
                }
            case .networkFailure(let error):
                fatalError(error.description)
            case .systemFailure(let error):
                fatalError(error.localizedDescription)
            }
        }
        

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

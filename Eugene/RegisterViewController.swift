//
//  RegisterViewController.swift
//  Eugene
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var companyTextField: UITextField!
    @IBOutlet var positionTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBAction func registerTapped(_ sender: UIButton) {
        //TOOD: figure how to do guard with less repetition
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text,
            let company = companyTextField.text,
            let position = positionTextField.text,
            let password = passwordTextField.text,
            !firstName.isEmpty,
            !lastName.isEmpty,
            !email.isEmpty,
            !company.isEmpty,
            !position.isEmpty,
            !password.isEmpty
            else {
                let ac = UIAlertController(title: "Register Failed", message: "Please ensure you have filled out all fields and try again.", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                ac.addAction(dismissAction)
                present(ac, animated: true)
                return
        }
        
        let user = Person(givenName: firstName, familyName: lastName, company: company, picture: nil, sharePicture: true, position: position, email: email)
        //TODO: remove code duplicatin with the network failure and system error cases
        register(user, withPassword: password) { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "eventList", sender: nil)
                }
            case .networkFailure(let response):
                    let ac = UIAlertController(title: "Login Failed", message: "An unexpected network error occured. Please try again or register a new account. (Code: \(response.statusCode)", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                    ac.addAction(dismissAction)
                    DispatchQueue.main.async {
                        self.present(ac, animated: true)
                        
                    }
            case .systemFailure(let error):
                fatalError("A system error has occured: \(error.localizedDescription)")

                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func register(_ user: Person, withPassword password: String, completion: @escaping (RequestResult) -> ()) {
        EugeneAPI.contactAPIFor(endPoint: .registerAccountEndpoint(user: user, password: password), completion: completion)
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

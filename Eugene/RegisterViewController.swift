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
        guard let firstName = firstNameTextField.text,
        let lastName = lastNameTextField.text,
        let email = emailTextField.text,
        let company = companyTextField.text,
        let position = positionTextField.text,
            let password = passwordTextField.text else {
                let ac = UIAlertController(title: "Register Failed", message: "Please ensure you have filled out all fields and try again.", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                ac.addAction(dismissAction)
                present(ac, animated: true)
                return
        }
        
        let user = Person(givenName: firstName, familyName: lastName, company: company, picture: UIImage(named: "ball")!, sharePicture: true, ID: 9665309, position: position, email: email)
        register(user, withPassword: password)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func register(_ user: Person, withPassword: String) {
        return
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

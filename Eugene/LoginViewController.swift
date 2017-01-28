//
//  LoginViewController.swift
//  Eugene
//
//  Created by Jonathon Day on 1/26/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func backToLoginRegister(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func registerTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "register", sender: nil)
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                return
        }
        
        EugeneAPI.contactAPIFor(endPoint: .loginEndpoint(email: email, password: password)) { [weak self] (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "eventList", sender: nil)
                }
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as? UITabBarController
        
        switch segue.identifier! {
        case "eventList":
            guard let eventListVC = navVC?.viewControllers?.first as? EventListViewController else {
                fatalError("Unexpected view controller after login")
            }
            eventListVC.dataSource = EventListDataSource()
        default:
            break
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

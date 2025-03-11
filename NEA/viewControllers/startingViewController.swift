//
//  startingViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 01/03/2025.
//

import UIKit

class startingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    //when teh register button is pressed, takes the user to register screen
    @IBAction func registerButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "registerScreen", sender: self)
        
    }
    // when the login button is pressed, takes the user to login screen
    @IBAction func loginButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "loginScreen", sender: self)
    }
    

}

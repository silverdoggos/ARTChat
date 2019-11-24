//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    
    
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text, let name = nameTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    self.ErrorLabel.backgroundColor = .red
                    print(e.localizedDescription)
                    self.ErrorLabel.text = e.localizedDescription
                } else {
                    let db = Auth.auth().currentUser?.createProfileChangeRequest()
                    db?.displayName = name
                    db?.commitChanges { (error) in
                        if let e = error {
                            print("Some Error - \(e)")
                        } else {
                            print("Name done")
                        }
                    }
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
            
        }
    }
}



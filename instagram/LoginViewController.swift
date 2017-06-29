//
//  LoginViewController.swift
//  instagram
//
//  Created by Xueying Wang on 6/27/17.
//  Copyright © 2017 Xueying Wang. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onSignIn(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: Error?) in
            if user != nil {
                print("you're logged in")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let newUser = PFUser()
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        newUser.setObject(UIImage(named: "profile_tab"), forKey: "avatar")
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("User created successfully")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
            } else {
                print(error?.localizedDescription ?? "error")
            }
        }
    }
    
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

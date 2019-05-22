//
//  SignInViewController.swift
//  Definetly Not Instagram
//
//  Created by Zapad on 01/05/2019.
//  Copyright © 2019 FMI. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func signInWithEmail(_ sender: Any) {
        let authUI = FUIAuth.defaultAuthUI()
        if let authViewController = authUI?.authViewController() {
            present(authViewController, animated: true, completion: nil)
        }
    }
    
}

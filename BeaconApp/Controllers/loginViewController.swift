//
//  loginViewController.swift
//  BeaconApp
//
//  Created by Anup Deshpande on 10/13/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class loginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorView: UIView!

    //MARK: API URL Declarations
    var loginAPI = "http://ec2-54-86-229-201.compute-1.amazonaws.com/api/user/login"
    
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.alpha = 0
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check for the token
        if preferences.string(forKey: "Token") != nil {
            self.performSegue(withIdentifier: "loginToShopSegue", sender: self)
        }
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
           if isEverythingFilled() == true{
               login(Email: emailTextField.text!, Password: passwordTextField.text!)
           }
    }
    
    func login(Email email:String, Password password:String){
        
        // MARK: LOGIN API REQUEST

        let parameters: [String:String] = [
            "email":email,
            "password":password
        ]
        
        
        AF.request(loginAPI,
                   method: .post,
                   parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    self.errorView.alpha = 0
                    
                    // Get token value from response
                    let json = JSON(value)
                    print(json)
                    if json["status"].stringValue == "200"{
                    let token = json["token"].stringValue
                    let customerId = json["customerId"].stringValue
                    print("Customer ID is  : \(customerId)")
                        
                    // Store token in UserDefaults
                    let preferences = UserDefaults.standard
                    preferences.set(token, forKey: "Token")
                    preferences.set(customerId, forKey: "customerId")
                    
                    // Start profile segue
                    self.performSegue(withIdentifier: "loginToShopSegue", sender: nil)
                    }
                    else if json["status"].stringValue == "400"{
                        self.errorLabel.text = json["message"].stringValue
                       
                        self.errorView.alpha = 1
                    }
                    
                    break
                    
                case .failure(let error):
                    print(error)
                    self.errorLabel.text = "Failed to call login API"
                    self.errorView.alpha = 1
                    break
                }
                
        }
        
    }
    
    
    func isEverythingFilled() -> Bool{
           
           var flag = true
           
           if emailTextField.text == "" {
               print("email is nil")
               flag = false
           }
            if passwordTextField.text == ""{
               print("password is nil")
               flag = false
           }
           
           return flag;
    }
}

extension loginViewController : UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}



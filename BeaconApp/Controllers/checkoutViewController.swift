//
//  checkoutViewController.swift
//  BeaconApp
//
//  Created by Anup Deshpande on 10/14/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn
import Alamofire
import SwiftyJSON
import GMStepper
import KRProgressHUD


class checkoutViewController: UIViewController {

    
    @IBOutlet weak var checkoutTableView: UITableView!
    @IBOutlet weak var totalAmount: UILabel!
    
    // MARK: API URL declarations
    let BTGetTokenAPI = "http://ec2-3-95-150-6.compute-1.amazonaws.com/api/payments/getToken"
    let BTCheckoutAPI = "http://ec2-3-95-150-6.compute-1.amazonaws.com/api/payments/checkout"
    
    var selectedProducts = [product]()
    var total:Double = 0
    var braintreeClient: BTAPIClient?
    var customerID:String?
    let preferences = UserDefaults.standard
    
     override func viewDidLoad() {
        super.viewDidLoad()
           
        checkoutTableView.dataSource = self
        checkoutTableView.delegate = self
        
        for product in selectedProducts {
            total = total + Double(product.price!)!
        }
           
        total = Double(round(1000*total)/1000)
        totalAmount.text = "$"+String(total)
           
        if preferences.object(forKey: "Token") == nil || preferences.object(forKey: "customerId") == nil{
            
            // Token not found
            print("Token not found")
            
        } else {
            
            customerID = preferences.string(forKey: "customerId")!
            
        }
                
           
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "checkoutToShopSegue", sender: nil)
    }
    
    //MARK: Braintree API calls
    
    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        
        if total > 0{
        fetchClientToken()
        }else{
         
            KRProgressHUD.showError(withMessage: "Cart is empty")
        }
        
    }
    
    func fetchClientToken() {
        
     print(customerID! + "cutsomer ID");
     let parameters: [String:String] = [
         "customerId":customerID!
     ]
     
     AF.request(BTGetTokenAPI,
                   method: .post,
                   parameters: parameters,
                encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    self.showDropIn(clientTokenOrTokenizationKey: json["clientToken"].stringValue)
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
        
        
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
            let request =  BTDropInRequest()
            let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
            { (controller, result, error) in
                if (error != nil) {
                    print(error ?? "Error Occured")
                } else if (result?.isCancelled == true) {
                    print("CANCELLED")
                } else if let result = result {
                    print("Result is")
                    
                    print(result.paymentMethod!.nonce)
                    self.postNonceToServer(paymentMethodNonce: result.paymentMethod!.nonce)
                }
                DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
                }
                
            }
            
            DispatchQueue.main.async {
                self.present(dropIn!, animated: true, completion: nil)
            }
            
        }
    
    
    func postNonceToServer(paymentMethodNonce: String) {
        
        print("nonce : " + paymentMethodNonce)
        let parameters: [String:String] = [
            "nounce":paymentMethodNonce,
            "amount":String(total)
            
        ]
        
        
        
        AF.request(BTCheckoutAPI,
                   method: .post,
                   parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    KRProgressHUD.showSuccess(withMessage: "Your order is placed")
                    
                    self.selectedProducts.removeAll()
                    self.checkoutTableView.reloadData()
                    
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "checkoutToShopSegue", sender: nil)
                    }
                    
                    break
                    
                case .failure(let error):
                    print(error)
                    break
                }
                
        }
    }
        


}


// MARK:Table View delegate Methods
extension checkoutViewController: UITableViewDelegate{
    
}

extension checkoutViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkoutTableView.dequeueReusableCell(withIdentifier: "checkoutCell", for: indexPath) as! checkoutTableViewCell
        
        print(selectedProducts[indexPath.row].name!)
        
            cell.productName.text = selectedProducts[indexPath.row].name!
            cell.productPrice.text = "$" + selectedProducts[indexPath.row].price!
            cell.ProductQuantity.value = Double(selectedProducts[indexPath.row].quantity)
            
            // Base64 to Image
            let productString = selectedProducts[indexPath.row].imageURL!
            
            if productString != "No Image"{
            let decodedData = NSData(base64Encoded: productString, options: .ignoreUnknownCharacters)
                cell.productImage.image = UIImage(data: decodedData! as Data)
            }
            else{
                cell.productImage.image = UIImage(named: "no-image")
            }
           
            cell.ProductQuantity.tag = indexPath.row
            
            cell.ProductQuantity.addTarget(self, action: #selector(self.stepperValueChanged), for: .valueChanged)
           
            return cell
    }
    
    @objc func stepperValueChanged(stepper: GMStepper) {
        selectedProducts[stepper.tag].quantity = Int(stepper.value)
        
        if Int(stepper.value) == 0 {
            
            let alert = UIAlertController(title: "Please confirm", message: "Are you sure you want to delete " + selectedProducts[stepper.tag].name!
                , preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            (alert) -> Void in
                self.selectedProducts.remove(at: stepper.tag)
                self.checkoutTableView.reloadData()
            })
            
            let deleteAction = UIAlertAction(title: "Cancel", style: .destructive,handler: {
            (alert) -> Void in
                stepper.value = stepper.value + 1
            })
            
            alert.addAction(confirmAction)
            alert.addAction(deleteAction)
            
            self.present(alert, animated: true, completion: nil)
            
           
        }

        calculateTotalAmount()
    }
    
    func calculateTotalAmount(){
        total = 0.00

        for product in selectedProducts {
            let quantity = product.quantity
            let price = Double(product.price!)
               
            total = total + Double(quantity) * price!
            total = Double(round(1000*total)/1000)
        }
           
        totalAmount.text = "$"+String(total)
    }
    
}

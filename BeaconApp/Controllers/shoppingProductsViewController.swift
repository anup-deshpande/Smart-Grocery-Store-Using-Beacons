//
//  ViewController.swift
//  BeaconApp
//
//  Created by Anup Deshpande on 10/9/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class shoppingProductsViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: API URL Declarations
    let getProductsAPI = "http://ec2-3-88-222-179.compute-1.amazonaws.com/api/store/fetchProducts"
    let getProductsByRegionAPI = "http://ec2-3-88-222-179.compute-1.amazonaws.com/api/store/fetchProductsByRegion"
    
    // Beacon Manager declarations
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
    identifier: "ranged region")
    
    let preferences = UserDefaults.standard
    var customerID:String?
    
    var products = [product]()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getShoppingProducts()
        
        if preferences.object(forKey: "Token") == nil || preferences.object(forKey: "customerId") == nil{
            // Token not found
            print("Token not found")
        } else {
             customerID = preferences.string(forKey: "customerId")!
        }
        
        
        beaconManager.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.beaconManager.requestAlwaysAuthorization()
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.beaconManager.startRangingBeacons(in: self.beaconRegion)
    }
    
    func getShoppingProducts(){
        
        
        
        AF.request(getProductsAPI)
            .responseJSON { (response) in
                
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                  
                    for parsedProduct in json["products"]{
                        self.products.append(product(json: parsedProduct.1))
                    }
                            
                    self.collectionView.reloadData()
                    
                    break
                case .failure(let error):
                    print(error)
                    break
                }
        }

        
        
    }
    
    func getShoppingProductsByRegion(region Region:String){
        
        let parameters: [String:String] = [
            "region":Region
        ]
        
        AF.request(getProductsByRegionAPI,
                      method: .post,
                      parameters: parameters,
                   encoding: JSONEncoding.default)
               .responseJSON { response in
                   switch response.result{
                   case .success(let value):
                       let json = JSON(value)
                       
                       self.products.removeAll()
                       
                       for parsedProduct in json["products"]{
                            self.products.append(product(json: parsedProduct.1))
                       }
                                                 
                       self.collectionView.reloadData()
                       
                       break
                       
                   case .failure(let error):
                       print(error)
                       break
                   }
                   
           }
        
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        logOut()
    }
    
    @IBAction func showCartButtonTapped(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "shopToCheckoutSegue", sender: nil)
    }
    
    
    func logOut(){
        // Delete Token from User Defaults
        let prefereces = UserDefaults.standard
        
        DispatchQueue.main.async {
            prefereces.set(nil, forKey: "Token")
            prefereces.set(nil, forKey: "customerId")
            prefereces.synchronize()
        }
        
        
        // Send back to login controller
        self.performSegue(withIdentifier: "shopToLoginSegue", sender: nil)
    }
    
}

//MARK: Beacon Manager Delegate Methods
extension shoppingProductsViewController : ESTBeaconManagerDelegate{
    
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        print(beacons.first!)
        
        if beacons.first!.major == 7518 && beacons.first!.minor == 47661{
            getShoppingProductsByRegion(region: "produce")
        }
        
        if beacons.first!.major == 45153 && beacons.first!.minor == 9209{
            getShoppingProductsByRegion(region: "lifestyle")
        }
        
    }
}


//MARK: CollectionViewDelegate Methods
extension shoppingProductsViewController: UICollectionViewDelegate{
    
}

extension shoppingProductsViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductsCollectionViewCell
        
        
        let discount = Double(products[indexPath.row].discount!)
        let originalPrice = Double(products[indexPath.row].price!)
        
        var discountedPrice = originalPrice! - (originalPrice! * (discount!/100))
        discountedPrice = (discountedPrice * 100).rounded()/100
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "$"+String(originalPrice!))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        cell.productName.text = products[indexPath.row].name!
       
        // Base64 to Image
        let productString = products[indexPath.row].imageURL!
        
        if productString != "No Image"{
        let decodedData = NSData(base64Encoded: productString, options: .ignoreUnknownCharacters)
            cell.productImage.image = UIImage(data: decodedData! as Data)
        }
        else{
            cell.productImage.image = UIImage(named: "no-image")
        }
        
        
        cell.addToCartButton.tag = indexPath.row
        cell.productOriginalPrice.attributedText = attributeString
        cell.productDiscountedPrice.text = "$"+String(discountedPrice)
        
        cell.addToCartButton.addTarget(self, action: #selector(self.addToCartButtonTapped), for: .touchUpInside)
        
        return cell
        
    }
    
    @objc func addToCartButtonTapped(sender: UIButton!){
        
        if(products[sender.tag].isAdded == true){
           sender.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
           sender.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            products[sender.tag].isAdded = false
            products[sender.tag].quantity = 0
           // selectedProducts.removeValue(forKey: sender.tag)
        }else{
            sender.setImage(UIImage(systemName: "cart.badge.minus"), for: .normal)
            sender.tintColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            products[sender.tag].isAdded = true
            products[sender.tag].quantity = 1
            //selectedProducts[sender.tag] = products[sender.tag]
        }
            
    }
    
    
}



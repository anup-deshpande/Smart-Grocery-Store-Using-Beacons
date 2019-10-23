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
import KRProgressHUD


class shoppingProductsViewController: UIViewController {
    
      var cycle = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // MARK: API URL Declarations
    let getProductsAPI = "http://ec2-3-95-150-6.compute-1.amazonaws.com/api/store/fetchProducts"
    let getProductsByRegionAPI = "http://ec2-3-95-150-6.compute-1.amazonaws.com/api/store/fetchProductsByRegion"
    
    // Beacon Manager declarations
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!,
    identifier: "ranged region")
    
    let preferences = UserDefaults.standard
    var customerID:String?
    
    var products = [product]()
    var selectedProducts = [product]()
    var previousBeacon:CLBeacon?
    
    var count1 = 0
    var count2 = 0
    var count3 = 0
    
 
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
                  
                    self.products.removeAll()
                    
                    for parsedProduct in json["products"]{
                        self.products.append(product(json: parsedProduct.1))
                    }
                    
                    // Sort products by region in place
                    self.products.sort { (product1, product2) -> Bool in
                        if product1.region! < product2.region!{
                            return true
                        }else{
                            return false
                        }
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
        
        print("Shopping products by region : \(Region)")
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "shopToCheckoutSegue":
            
            // Add selected products to cart
            let destination = segue.destination as! checkoutViewController
            destination.selectedProducts = self.selectedProducts
            
            break
            
        default:
            break
        }
    }
    
}

//MARK: Beacon Manager Delegate Methods
extension shoppingProductsViewController : ESTBeaconManagerDelegate{
    
  
    
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        cycle += 1
        
        print(beacons)
        print("Cycle : \(cycle)")                      
        print("produce count = \(count1)")
        print("lifestyle count = \(count2)")
        print("grocery count = \(count3)")
        
        
        if cycle == 5{
            
            cycle = 0
            
            if count1 > count2 && count1 > count3{
                getShoppingProductsByRegion(region: "produce")
            }
            else if count2 > count1 && count2 > count3{
                getShoppingProductsByRegion(region: "lifestyle")
            }
            else if count3 > count1 && count3 > count2{
                getShoppingProductsByRegion(region: "grocery")
            }
            
            count1 = 0
            count2 = 0
            count3 = 0
        }
        
        

       
        var flag = true
        for beacon in beacons{
            
            if beacon.major == 26535 && beacon.minor == 44799{
                
                count1 = count1 + 1

//                if count1 > 3{
//
//                    if previousBeacon == nil{
//
//                        previousBeacon = beacon
//                        getShoppingProductsByRegion(region: "produce")
//
//                        flag = false
//                        return
//
//                    }else{
//
//                        if previousBeacon!.major == beacon.major && previousBeacon!.minor == beacon.minor{
//
//                            return
//                        }
//                        else{
//
//                            previousBeacon = beacon
//                            getShoppingProductsByRegion(region: "produce")
//                            flag = false
//                            return
//                        }
//                    }
//
//                }
                
                return
                
                      
            }
                   
            if beacon.major == 49427 && beacon.minor == 46246{
                      
                
                count2 = count2 + 1

                
//                if count2 > 3{
//                if previousBeacon == nil{
//
//                    previousBeacon = beacon
//                    getShoppingProductsByRegion(region: "lifestyle")
//                    flag = false
//                    return
//
//
//
//                }else{
//
//                    if previousBeacon!.major == beacon.major && previousBeacon!.minor == beacon.minor{
//                        return
//                    }else{
//
//                        previousBeacon = beacon
//                        getShoppingProductsByRegion(region: "lifestyle")
//                        flag = false
//                        return
//
//                    }
//
//                }
//                }
                
                return
                  
            }
            
            // Code for third Beacon
            
            if beacon.major == 15326 && beacon.minor == 56751{

                count3 = count3 + 1

//                if count3 > 3{
//                if previousBeacon == nil{
//
//                    previousBeacon = beacon
//                    getShoppingProductsByRegion(region: "grocery")
//                    flag = false
//                    return
//
//
//
//                }else{
//
//                    if previousBeacon!.major == beacon.major && previousBeacon!.minor == beacon.minor{
//                        return
//                    }else{
//
//                        previousBeacon = beacon
//                        getShoppingProductsByRegion(region: "grocery")
//                        flag = false
//                        return
//
//                    }
//
//                }
//
//                }
                
                return

            }
            
        }
       
        if flag == true{
            getShoppingProducts()
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
        
        
        var flag = true
        
        for product in selectedProducts{
            if product.name! == products[sender.tag].name!{
                product.quantity = product.quantity + 1
                flag = false
            }
        }
        
        
    
        if flag == true{
        selectedProducts.append(products[sender.tag])
        }
        
        KRProgressHUD.showSuccess(withMessage: "\(products[sender.tag].name!) is added to cart")
        
    }
    
    
}



//
//  product.swift
//  BeaconApp
//
//  Created by Anup Deshpande on 10/13/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import Foundation
import SwiftyJSON

class product{
    
    // Properties parsed from JSON
    var name:String?
    var imageURL:String?
    var price:String?
    var region:String?
    var discount:String?
    
    // Properties that are calculated after
    var isAdded:Bool = false
    var quantity:Int = 0
    
    
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.imageURL = json["photo"].stringValue
        self.discount = json["discount"].stringValue
        self.price = json["price"].stringValue
        self.region = json["region"].stringValue
   }
    
    
}


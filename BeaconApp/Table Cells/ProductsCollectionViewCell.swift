//
//  ProductsCollectionViewCell.swift
//  BeaconApp
//
//  Created by Anup Deshpande on 10/13/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit

class ProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productOriginalPrice: UILabel!
    @IBOutlet weak var productDiscountedPrice: UILabel!
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var addToCartButton: UIButton!
    

}

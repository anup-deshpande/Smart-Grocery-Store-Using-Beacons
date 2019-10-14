//
//  checkoutTableViewCell.swift
//  BeaconApp
//
//  Created by Anup Deshpande on 10/14/19.
//  Copyright © 2019 Anup Deshpande. All rights reserved.
//

import UIKit
import GMStepper

class checkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
       
    @IBOutlet weak var ProductQuantity: GMStepper!
       
    override func awakeFromNib() {
        super.awakeFromNib()
        ProductQuantity.labelFont = UIFont(name: "Helvetica", size: 16.0)!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

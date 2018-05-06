//
//  ProductTableViewCell.swift
//  EvertonTeotonio
//
//  Created by user140056 on 5/5/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbState: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbCard: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

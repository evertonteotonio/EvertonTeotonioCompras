//
//  StateTableViewCell.swift
//  EvertonTeotonio
//
//  Created by user140056 on 5/5/18.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    @IBOutlet weak var lbStateName: UILabel!
    @IBOutlet weak var lbStateTax: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

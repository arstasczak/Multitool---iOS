//
//  myCellTableViewCell.swift
//  MultiTool
//
//  Created by Arkadiusz Staśczak on 09.02.2018.
//  Copyright © 2018 Arkadiusz Staśczak. All rights reserved.
//

import UIKit

class myTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateCell(name: String, value: Float){
        self.nameLabel.text = name
        self.valueLabel.text = value.description
    }
    
}

//
//  ShowTableViewCell.swift
//  RappiMDB Yair
//
//  Created by Yair Saucedo on 20/11/21.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

    @IBOutlet weak var imageShow: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

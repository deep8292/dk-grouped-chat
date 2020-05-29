//
//  SenderCell.swift
//  GroupedChat
//
//  Created by Khiwani, Deepak   on 25/05/20.
//  Copyright © 2020 Khiwani, Deepak  . All rights reserved.
//

import UIKit

class SenderCell: UITableViewCell {
    
    @IBOutlet weak var message: UITextView!
    
    @IBOutlet weak var messageBackground: UIImageView!
    @IBOutlet weak var maxWidth: NSLayoutConstraint!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.messageBackground.layer.cornerRadius = 16
        self.messageBackground.layer.masksToBounds = true
        
        maxWidth.constant = UIScreen.main.bounds.size.width * 0.7
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
    layerMaxXMaxYCorner – lower right corner
    layerMaxXMinYCorner – top right corner
    layerMinXMaxYCorner – lower left corner
    layerMinXMinYCorner – top left corner
    */
    
    func setRounded() {
        self.messageBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    func setCenterStyle() {
        self.messageBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    func setLastMessageStyle() {
        self.messageBackground.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
    }
    
    func setFirstMessageStyle() {
        self.messageBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }

}

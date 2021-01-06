//
//  DateHeader.swift
//  GroupedChat
//
//  Created by Khiwani, Deepak   on 29/05/20.
//  Copyright © 2020 Khiwani, Deepak  . All rights reserved.
//

import Foundation
import UIKit

class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.chatColor.dateHeaderColor
        textColor = .white
        textAlignment = .center
        font = UIFont.chatFont.dateHeader
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        let height = originalSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalSize.width + 16, height: height)
    }
    
    func setDate(with date: String) {
        self.text = date
    }
}


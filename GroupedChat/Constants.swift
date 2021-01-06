//
//  Constants.swift
//  GroupedChat
//
//  Created by Khiwani, Deepak   on 26/05/20.
//  Copyright © 2020 Khiwani, Deepak  . All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  struct chatColor {
    static var dateHeaderColor: UIColor  { return UIColor(red: 1/255, green: 25/255, blue: 147/255, alpha: 0.4) }
    static var buttonColor: UIColor  { return UIColor(red: 1/255, green: 25/255, blue: 147/255, alpha: 1) }
  }
}

extension UIFont {
    struct chatFont {
        static var dateHeader: UIFont { UIFont(name: "Verdana", size: 11)! }
        static var sendButton: UIFont { UIFont(name: "Verdana", size: 14)! }
        static var inputBox: UIFont { UIFont(name: "Verdana", size: 14)! }
        static var bubble: UIFont { UIFont(name: "Verdana", size: 14)! }
    }
}

extension Date {
    func createDateForHeader() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return DateFormatter().string(from: self)
        }
    }
}

extension String {

   func removingAllWhitespaces() -> String {
       return removingCharacters(from: .whitespaces)
   }

   func removingCharacters(from set: CharacterSet) -> String {
       var newString = self
       newString.removeAll { char -> Bool in
           guard let scalar = char.unicodeScalars.first else { return false }
           return set.contains(scalar)
       }
       return newString
   }
}

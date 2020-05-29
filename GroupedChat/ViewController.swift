//
//  ViewController.swift
//  GroupedChat
//
//  Created by Khiwani, Deepak   on 25/05/20.
//  Copyright © 2020 Khiwani, Deepak  . All rights reserved.
//

import UIKit

struct ChatMessage {
    let message: String
    let timeStamp: String
    let isSender: Bool
}


class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputToolbar: DKTextInputBar!
    
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var messageSource: [ChatMessage] = []
    private var messages = [[ChatMessage]]()
    
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        registerKeyboardNotifcations()
    }
}

// MARK: Register Keyboard Notifications
extension ViewController {
    
    private func registerKeyboardNotifcations() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardShown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: IBAction to recieve messages
extension ViewController {
    
    @IBAction func didTapRefresh(_ sender: Any) {
        let receivedMessages = [
            ChatMessage(message: "Hi", timeStamp: dateFormatter.string(from: Date()), isSender: false),
            ChatMessage(message: "I am good", timeStamp: dateFormatter.string(from: Date()), isSender: false),
            ChatMessage(message: "How are you?", timeStamp: dateFormatter.string(from: Date()), isSender: false),
        ]
        
        receivedMessages.forEach { (message) in
//            self.messageSource.append(message)
            self.assembleToGroup(message: message, isReceiving: true)
        }
    }
}

// MARK: Setup Toolbar
extension ViewController {
    
    private func setupToolbar() {
        
        inputToolbar.didChangeHeight = { textView in
            let size = CGSize(width: self.view.frame.size.width, height: .infinity)
            
            let estimatedSize = textView.sizeThatFits(size)

            self.toolbarHeight.constant = estimatedSize.height + 16
            self.scrollToBottom()
        }
        
        inputToolbar.finishSendingMessage = { message in
            let message = ChatMessage(message: message, timeStamp: "28/05/2020", isSender: true)
            self.assembleToGroup(message: message)
        }
        
    }
}

// MARK: Table DataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.section]
        
        let isSender = message[indexPath.row].isSender
        
        if isSender {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell") as? SenderCell else {
                return UITableViewCell()
            }
            cell.message.text = message[indexPath.row].message
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell") as? ReceiverCell else {
                return UITableViewCell()
            }
            cell.message.text = message[indexPath.row].message
            
            return cell
        }
    }
}

// MARK: Table Delegates
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let dateLabel = DateHeaderLabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.text = messages[section].first?.timeStamp
        
        let containerView = UIView()
        containerView.addSubview(dateLabel)
    
        dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    
        return containerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
}

// MARK: Keyboard Notifications
extension ViewController {
    
    @objc func keyboardShown(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        let isKeyboardShowing = notification.name ==  UIResponder.keyboardWillShowNotification
        bottomConstraint.constant =  isKeyboardShowing ? keyboardFrame.height : 0
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }, completion: nil)
    }
}


// MARK: Table Helper Methods
extension ViewController {
    
    // Call this method when getting all the messages
    func assembleToGroups() {
        
        let dates = Dictionary(grouping: messageSource) { (element) -> Date in
            return dateFormatter.date(from: element.timeStamp) ?? Date()
        }
        
        let sorted = dates.keys.sorted()
        sorted.forEach { (key) in
            let value = dates[key]
            messages.append(value ?? [])
        }
        tableView.reloadData()
    }
    
    // Method to update the current chat
    func assembleToGroup(message: ChatMessage, isReceiving: Bool = false) {
        var dates = Dictionary(grouping: messageSource) { (element) -> Date in
            return dateFormatter.date(from: element.timeStamp) ?? Date()
        }
        let dateFromMessage: Date = dateFormatter.date(from: message.timeStamp) ?? Date()
        let result = dates.keys.contains(dateFromMessage)
        if result {
            let indexOfDate = messages.firstIndex(where: { dateFormatter.date(from: $0.first!.timeStamp)!.compare(dateFromMessage) == .orderedSame })
            var values = messages[indexOfDate ?? 0]
            values.append(message)
            messageSource.append(message)
            messages[indexOfDate ?? 0] = values
        } else {
            dates[dateFromMessage] = [message]
            messageSource.append(message)
            messages.append(dates[dateFromMessage] ?? [])
        }
        tableView.reloadData()

        scrollToBottom()
    }
    
    func scrollToBottom() {
        if messages.count > 1 {
            
            let lastIndex = messages.count - 1
            let indexRow = messages[lastIndex].count
            
            tableView.scrollToRow(at: IndexPath(row: indexRow - 1, section: lastIndex), at: .bottom, animated: false)
        }
    }
}

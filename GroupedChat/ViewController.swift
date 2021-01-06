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

struct Message {
    let message: String
    let date: Date
    let isSender: Bool
}


class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputToolbar: DKInputBar!
    
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    
    private var isBezleLessDevice = false
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint! {
        didSet {
            if UIScreen.main.nativeBounds.height > 2208 || UIScreen.main.nativeBounds.height >= 1792  {
                isBezleLessDevice = true
                bottomConstraint.constant = bottomConstraint.constant + 16
            }
        }
    }
    
    private var messageSource: [ChatMessage] = []
    private var messages = [[ChatMessage]]()
    
    private var groupedMessages = [[Message]]()
    
    
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
            Message(message: "Hi", date: Date(), isSender: false),
            Message(message: "I am a hard coded bot 😄", date: Date(), isSender: false)
        ]
        
        receivedMessages.forEach { [weak self] (message) in
            guard let strongSelf = self else { return } // Always do that when using blocks
            strongSelf.insertMessageInList(chat: message)
        }
    }
}

// MARK: Setup Toolbar
extension ViewController {
    
    private func setupToolbar() {
        
        inputToolbar.didBeginEdit = {_ in
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }, completion: nil)
        }
        
        inputToolbar.didChangeHeight = { height in
            if height > self.toolbarHeight.constant {
                UIView.animate(withDuration: 0.1) {
                    self.view.layoutIfNeeded()
                    self.scrollToBottom()
                }
            }
            self.toolbarHeight.constant = height
        }
        
        inputToolbar.finishSendingMessage = { [weak self] message in
            guard let strongSelf = self else { return } // Always do that when using blocks
            let object = Message(message: message, date: Date(), isSender: true)
            strongSelf.insertMessageInList(chat: object, isSending: true)
        }
    }
}

// MARK: Table DataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedMessages[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellForIndexPath(with: indexPath)
    }
}

// MARK: Table Delegates
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        createDateHeader(with: section)
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
        bottomConstraint.constant =  isKeyboardShowing ? keyboardFrame.height : isBezleLessDevice ? 16 : 8
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }, completion: nil)
    }
}

// MARK: TableView UI Helpers
extension ViewController {
    
    private func createDateHeader(with section: Int) -> UIView {
        guard
            let date = groupedMessages[section].first?.date
        else { return UIView() }
        
        let dateLabel = DateHeaderLabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.setDate(with: date.createDateForHeader())
        
        let containerView = UIView()
        containerView.addSubview(dateLabel)
        dateLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    
        return containerView
    }
    
    private func getCellForIndexPath<T>(with indexPath: IndexPath) -> T {
        let message = groupedMessages[indexPath.section][indexPath.row]
        
        if message.isSender {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell") as? SenderCell else {
                return UITableViewCell() as! T
            }
            cell.setupMessage(with: message)
            return cell as! T
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell") as? ReceiverCell else {
                return UITableViewCell() as! T
            }
            cell.setupMessage(with: message)
            return cell as! T
        }
    }
}

// MARK: List Populator Helpers
extension ViewController {
    
    private func insertMessageInList(chat: Message, isSending: Bool = false) {
        var lastDate = Date()
        let lastSection = groupedMessages.count
        if groupedMessages.count > 0 {
            guard let d = groupedMessages[lastSection - 1].last?.date else { return }
            lastDate = d
        }
        
        if dateFormatter.string(from: lastDate) == dateFormatter.string(from: Date()) && groupedMessages.count > 0  {
            var lastArray = groupedMessages[lastSection - 1]
            lastArray.append(chat)
            
            groupedMessages.remove(at: lastSection - 1)
            groupedMessages.insert(lastArray, at: lastSection - 1)

            tableView.insertRows(at: [IndexPath(row: groupedMessages[lastSection - 1].count - 1, section: lastSection - 1)], with: isSending ? .right : .left)
        } else {
            groupedMessages.append([chat])
            
            let index = IndexSet(integer: groupedMessages.count - 1)
            
            tableView.insertSections(index, with: .none)
            
//            tableView.performBatchUpdates {
//                tableView.insertSections(index, with: isSending ? .right : .left)
//            } completion: { (update) in
//                print(update)
//            }
        }
        
        UIView.animate(withDuration: 0) {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    private func scrollToTop() {
        if groupedMessages.count >= 1 {
            let lastIndex = self.groupedMessages.count - 1
            let indexRow = self.groupedMessages[lastIndex].count
            
            self.tableView.scrollToRow(at: IndexPath(row: indexRow - 1, section: lastIndex), at: .top, animated: true)
        }
    }
    
    private func scrollToBottom() {
        if groupedMessages.count >= 1 {
            let lastIndex = self.groupedMessages.count - 1
            let indexRow = self.groupedMessages[lastIndex].count
            
            self.tableView.scrollToRow(at: IndexPath(row: indexRow - 1, section: lastIndex), at: .bottom, animated: true)
        }
    }
}



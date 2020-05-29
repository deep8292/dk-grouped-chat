//
//  DKInputBar.swift
//  GroupedChat
//
//  Created by Khiwani, Deepak   on 26/05/20.
//  Copyright © 2020 Khiwani, Deepak  . All rights reserved.
//

import UIKit


class DKTextInputBar: UIView {
    
    private var textView: UITextView!
    private var sendButton: UIButton!
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()
    
    var maxSizeToGrow: CGFloat = 120
    
    var textFont = UIFont(name: "Verdana", size: 14)
    
    // Notify when textViewChangesHeight
    var didChangeHeight:((_ textView: UITextView) -> ())? = nil
    // Notify when message is ready to send
    var finishSendingMessage:((_ message: String) -> ())? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupTextViewAndSendButton()
        addConstraints()
    }
    
    /* Uncomment if you're dealing programmatically
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextView()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     */
}

// Settin up views
extension DKTextInputBar {
    
    private func setupTextViewAndSendButton() {
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.font = textFont
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.chatColor.buttonColor.cgColor
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        
        sendButton = UIButton(frame: CGRect(x: self.frame.size.width - 60, y: 0, width: 60, height: 44))
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.chatFont.sendButton
        sendButton.layer.borderColor = UIColor.chatColor.buttonColor.cgColor
        sendButton.layer.borderWidth = 1
        sendButton.setTitleColor(UIColor.chatColor.buttonColor, for: .normal)
        sendButton.layer.cornerRadius = 8
        sendButton.layer.masksToBounds = true
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        self.addSubview(textView)
        self.addSubview(sendButton)
    }
    
    
    private func addConstraints() {
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        [
            sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
            ].forEach({ $0.isActive = true})
        
        
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        [
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: -(sendButton.frame.size.width + 8)),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            ].forEach({ $0.isActive = true })
    }
}

extension DKTextInputBar {
    
    @objc private func didTapSend() {
        // Preventing an empty message to be sent
        guard textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0  else { return }
        
        if let sendMessage = finishSendingMessage {
            sendMessage(textView.text)
        }
        textView.text = ""
    }
}

extension DKTextInputBar: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: self.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
                
        if estimatedSize.height >= maxSizeToGrow {
            textView.isScrollEnabled = true
        } else {
            if let callback = self.didChangeHeight {
                callback(textView)
            }
        }
    }
}

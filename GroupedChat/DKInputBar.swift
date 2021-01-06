//
//  DKInputBar.swift
//  GroupedChat
//
//  Created by Khiwani, Deepak   on 25/05/20.
//  Copyright © 2020 Khiwani, Deepak  . All rights reserved.
//

import UIKit

@objc protocol DKInputBarDelegate {
    @objc optional func textViewDidChangeToNewHeight(_ textView: UITextView, height: CGFloat)
    @objc optional func textViewDidBeginEdit(_ textView: UITextView, height: CGFloat)
    @objc optional func textViewDidFinishSendingMessage(_ message: String)
}

class DKInputBar: UIView {
    
    //MARK: User Interface
    private var textView: UITextView!
    private var sendButton: UIButton!
    private var attachmentButton: UIButton!
    private var placeHolderLabel: UILabel!
    private var borderView: UIView!
    
    // MARK: Public Props
    private var placeHolderText = "Type a message"
    private var minimumHeight: CGFloat = 48
    public var maximumHeight: CGFloat = 110
    public var textFont = UIFont.chatFont.inputBox
    
    // MARK: Callback Methods
    // Notify when textViewChangesHeight
    public var didChangeHeight:((_ newHeight: CGFloat) -> ())? = nil
    // Notify when message is ready to send
    public var finishSendingMessage:((_ message: String) -> ())? = nil
    // Notify when user just begin to edit
    public var didBeginEdit:((_ textView: UITextView) -> ())? = nil
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.backgroundColor = .clear
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
extension DKInputBar {
    
    private func setupTextViewAndSendButton() {
        textView = UITextView()
        textView.font = textFont
        textView.textContainer.heightTracksTextView = true
        textView.delegate = self
        textView.isScrollEnabled = false
        
        placeHolderLabel = UILabel()
        placeHolderLabel.text = placeHolderText
        placeHolderLabel.textColor = UIColor.lightGray
        placeHolderLabel.font = textFont
        
        sendButton = UIButton()
        sendButton.titleLabel?.font = UIFont.chatFont.sendButton
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor.chatColor.buttonColor, for: .normal)
        sendButton.isUserInteractionEnabled = false
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        attachmentButton = UIButton(type: .contactAdd)
        attachmentButton.tintColor = UIColor.chatColor.buttonColor
        attachmentButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        borderView = UIView()
        borderView.backgroundColor = .clear
        borderView.layer.cornerRadius = 24
        borderView.clipsToBounds = true
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.addSubview(attachmentButton)
        self.addSubview(borderView)
        borderView.addSubview(sendButton)
        borderView.addSubview(textView)
        textView.addSubview(placeHolderLabel)
    }
    
    
    private func addConstraints() {
        
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        [
            attachmentButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            attachmentButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            attachmentButton.heightAnchor.constraint(equalToConstant: 50),
            attachmentButton.widthAnchor.constraint(equalToConstant: 0)
        ].forEach({ $0.isActive = true })
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        [
            borderView.leadingAnchor.constraint(equalTo: attachmentButton.trailingAnchor, constant: 0),
            borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            borderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        ].forEach({ $0.isActive = true })
        
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        [
            sendButton.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
        ].forEach({ $0.isActive = true })
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        [
            textView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -8)
        ].forEach({ $0.isActive = true })
        
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        [
            placeHolderLabel.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: 4),
            placeHolderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor)
        ].forEach({ $0.isActive = true })
    }
}

extension DKInputBar {
    
    @objc private func didTapSend() {
        // Preventing an empty message to be sent
        guard textView.text.removingCharacters(from: .whitespacesAndNewlines).count != 0  else { return }
        if let sendMessage = finishSendingMessage {
            sendMessage(textView.text)
        }
        textView.text = ""
        placeHolderLabel.isHidden = false
        textViewDidChange(textView)
    }
}

extension DKInputBar: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let callback = didBeginEdit {
            callback(textView)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.removingCharacters(from: .whitespacesAndNewlines).count > 0 {
            placeHolderLabel.isHidden = true
            sendButton.isUserInteractionEnabled = true
        } else {
            placeHolderLabel.isHidden = false
        }
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if let callback = didChangeHeight {
            if estimatedSize.height <= minimumHeight {
                callback(minimumHeight)
            } else if estimatedSize.height >= maximumHeight {
                textView.isScrollEnabled = true
                callback(maximumHeight)
            } else {
                callback(estimatedSize.height + 16)     // 16px is top and bottom space of textview from its parent
            }
        }
    }
}


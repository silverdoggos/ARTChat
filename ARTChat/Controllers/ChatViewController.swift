//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        navigationItem.title = K.appName
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()

    }
    
    func loadMessages() {
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshop, error) in
            self.messages = []
            if let e = error {
                print("There was an issue retreiving data from Firestore. \(e)")
            } else {
                if let snapshopDocuments = querySnapshop?.documents{
                    for doc in snapshopDocuments {
                        let data = doc.data()
                        if let sender = data[K.FStore.senderField] as? String, let message = data[K.FStore.bodyField] as? String, let name = data[K.FStore.nameField] as? String  {
                            let newMessange = Message(sender: sender, body: message, name: name)
                            self.messages.append(newMessange)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let bodyMessage = messageTextfield.text, let senderMessage = Auth.auth().currentUser?.email, let nameSender = Auth.auth().currentUser?.displayName  {
            db.collection(K.FStore.collectionName).addDocument(data:
                [
                K.FStore.senderField: senderMessage,
                K.FStore.bodyField: bodyMessage,
                K.FStore.dateField: Date().timeIntervalSince1970,
                K.FStore.nameField: nameSender
                ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore: \(e)")
                } else {
                    print("all done")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        } else {
            print("something is not done")
        }
        
    }
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
           do {
             try Auth.auth().signOut()
             navigationController?.popToRootViewController(animated: true)
           } catch let signOutError as NSError {
             print ("Error signing out: %@", signOutError)
           }
       }

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        as! MessageCell
        cell.label.text = message.body
        cell.nameLabel.text = message.name
        
        //This is a message from current user
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
            cell.nameLabel.isHidden = true
        }
        //This is a message from another user
        else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            cell.nameLabel.isHidden = false
        }
        
        return cell
    }
    
}



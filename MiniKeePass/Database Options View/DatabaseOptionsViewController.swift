//
//  DatabaseOptionsViewController.swift
//  MiniKeePass
//
//  Created by Tait Smith on 4/17/17.
//  Copyright © 2017 Self. All rights reserved.
//

import Foundation

class DatabaseOptionsViewController: UITableViewController {

    //MARK: Properties
    @IBOutlet weak var encryptionName: UITableViewCell!
    @IBOutlet weak var encrpytionRounds: UITextField!
    @IBOutlet weak var keyDerivationName: UITableViewCell!
    @IBOutlet weak var keyDerivationIterations: UITextField!

    fileprivate let encryptionTypes = ["AES", "TwoFish", "ChaCha20"]
    fileprivate let keyDerivationTypes = ["AES-KDF", "Argon2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectionViewController = segue.destination as! SelectionViewController
        if (segue.identifier == "Encryption") {
            selectionViewController.items = encryptionTypes
            selectionViewController.selectedIndex = 0
            selectionViewController.itemSelected = { (selectedIndex) in
               /* self.appSettings.setPinLockTimeoutIndex(selectedIndex) */
                self.navigationController?.popViewController(animated: true)
            }
        } else if (segue.identifier == "KeyDerivation") {
            selectionViewController.items = keyDerivationTypes
            selectionViewController.selectedIndex = 0 /*appSettings.deleteOnFailureAttemptsIndex()*/
            selectionViewController.itemSelected = { (selectedIndex) in
                /*self.appSettings.setDeleteOnFailureAttemptsIndex(selectedIndex)*/
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            assertionFailure("Unknown segue")
        }
    }
    
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

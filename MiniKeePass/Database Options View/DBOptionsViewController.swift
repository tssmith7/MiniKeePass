//
//  DBOptionsViewController.swift
//  MiniKeePass
//
//  Created by Tait Smith on 4/17/17.
//  Copyright © 2017 Self. All rights reserved.
//

import UIKit

class DBOptionsViewController: UITableViewController, UITextFieldDelegate {
    
    fileprivate enum Section : Int {
        case dbInfo = 0
        case encryptionAlgo = 1
        case keyDerivationFunc = 2
        
        static let AllValues = [Section.dbInfo, Section.encryptionAlgo, Section.keyDerivationFunc]
    }
    
    fileprivate let sectionTitles = [ "DATABASE INFORMATION",
                                      "ENCRYPTION ALGORITHM",
                                      "KEY DERIVATION FUNCTION"]
    fileprivate let sectionFootnotes = [ "",
                                         "Algorithm used to encrypt the contents of the database.",
                                         "Method used to encrypt the master database password.  More iterations is more secure but requires longer to open the database."]
    
    fileprivate let databaseInfoCells = ["LabelCell", "LabelCell"]
    fileprivate let encryptionCells = ["DisclosureCell"]
    fileprivate let keyDerivCells = ["DisclosureCell", "NumberCell",
                                     "NumberCell", "NumberCell"]
    
    fileprivate let encryptionMethodLabel = "Algorithm"
    fileprivate let encryptionNames = [["AES", "TwoFish"],
                                       ["AES", "ChaCha20"]]
    
    fileprivate let keyDerivMethodLabel = "Function"
    fileprivate let keyDerivNamesKdb4 = ["AES-KDF", "Argon2"]
    fileprivate let keyDerivRowLabels = [["Rounds"],
                                         ["Iterations", "Memory", "Parallelism"]]

    fileprivate var keyDerivValueMap = [String: UInt]()
    fileprivate var textFieldMap = [String: UITextField]()
    fileprivate var initialSettings = [UInt]()
    fileprivate var databaseInfoLabel = ""
    fileprivate var encryptionNameIndex = 0
    fileprivate var keyDerivNameIndex = 0
    
    fileprivate var databaseDocument: DatabaseDocument!
    fileprivate var isKdb4: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseDocument = MiniKeePassAppDelegate.getDelegate()!.databaseDocument!
        isKdb4 = databaseDocument.kdbTree is Kdb4Tree
        
        if( isKdb4 ) {
            let tree = databaseDocument.kdbTree as! Kdb4Tree
            databaseInfoLabel = tree.databaseName + " (Version 2.x)\n"
            databaseInfoLabel += tree.databaseDescription
            encryptionNameIndex = uuidToEncryptionIndex(tree.encryptionAlgorithm)
            let d = tree.kdfParams[KDF_KEY_UUID_BYTES] as! Data
            keyDerivNameIndex = setupKeyDerivationValues(d)
            // Remember the current database settings.
            initialSettings = [UInt(encryptionNameIndex),
                               UInt(keyDerivNameIndex),
                               keyDerivValueMap[keyDerivRowLabels[1][0]]!,
                               keyDerivValueMap[keyDerivRowLabels[1][1]]!,
                               keyDerivValueMap[keyDerivRowLabels[1][2]]! ]
        } else {
            let tree = databaseDocument.kdbTree as! Kdb3Tree
            databaseInfoLabel = "(Version 1.x) Database\n"
            if( (UInt8(tree.flags) & UInt8(FLAG_RIJNDAEL)) > 0 ) {
                encryptionNameIndex = 0
            } else {
                encryptionNameIndex = 1
            }
            keyDerivValueMap[keyDerivRowLabels[0][0]] = UInt(tree.rounds)
            // Remember the current database settings.
            initialSettings = [UInt(encryptionNameIndex),
                               keyDerivValueMap[keyDerivRowLabels[0][0]]!]
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionFootnotes[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        
        switch Section.AllValues[section] {
        case .dbInfo:
            return 1
        case .encryptionAlgo:
            return 1
        case .keyDerivationFunc:
            if( keyDerivNameIndex == 1 ) {
                return 4
            } else {
                return 2
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        var cellLabel: String?
        
        // Get the table cells
        switch Section.AllValues[indexPath.section] {
        case .dbInfo:
            cell = tableView.dequeueReusableCell(withIdentifier: databaseInfoCells[indexPath.row], for: indexPath)
            cell.textLabel!.text = databaseInfoLabel
        case .encryptionAlgo:
            cell = tableView.dequeueReusableCell(withIdentifier: encryptionCells[indexPath.row], for: indexPath)
            let isKdb4Index = isKdb4==true ? 1 : 0
            cell.textLabel!.text = encryptionMethodLabel
            cell.detailTextLabel?.text = encryptionNames[isKdb4Index][encryptionNameIndex]
        case .keyDerivationFunc:
            cell = tableView.dequeueReusableCell(withIdentifier: keyDerivCells[indexPath.row], for: indexPath)
            if(indexPath.row == 0) {
                cell.textLabel!.text = keyDerivMethodLabel
                cell.detailTextLabel!.text = keyDerivNamesKdb4[keyDerivNameIndex]
                if( !isKdb4 ){
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.isEnabled = false
                    cell.detailTextLabel?.isEnabled = false
                }
            } else {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(numberCellTouched))
                cell.addGestureRecognizer(tapGesture)
                let label = cell.viewWithTag(1) as! UILabel
                cellLabel = keyDerivRowLabels[keyDerivNameIndex][indexPath.row-1]
                label.text = cellLabel
                let textF = cell.viewWithTag(2) as! UITextField
                textF.delegate = self
                textFieldMap[cellLabel!] = textF
            }
        }
        
        if( cellLabel != nil ) {
            textFieldMap[cellLabel!]?.text = "\(keyDerivValueMap[cellLabel!]!)"
        }
        
        return cell
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        // If a number cell is being edited then validate the contents
        // before leaving the page.
        for (_, textField) in textFieldMap {
            if textField.isFirstResponder {
                if !textFieldShouldEndEditing(textField) {
                    return
                }
                textField.resignFirstResponder()
            }
        }
        var newSettings = [UInt]()
        
        if( isKdb4 ) {
            newSettings = [UInt(encryptionNameIndex),
                           UInt(keyDerivNameIndex),
                           keyDerivValueMap[keyDerivRowLabels[1][0]]!,
                           keyDerivValueMap[keyDerivRowLabels[1][1]]!,
                           keyDerivValueMap[keyDerivRowLabels[1][2]]! ]
        } else {
            newSettings = [UInt(encryptionNameIndex),
                           keyDerivValueMap[keyDerivRowLabels[0][0]]!]
        }

        if( newSettings != initialSettings ) {
            // Copy the UI settings into the database tree
            changeDatabaseValues()
            // The settings were changed, we need to save the database
            databaseDocument.save()
        }

        dismiss( animated:true, completion:nil )
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        // If a number cell is being edited then throw away the contents
        // before leaving the page.
        for (_, textField) in textFieldMap {
            if textField.isFirstResponder {
                // Put some valid text in the field to make sure it
                // is happy to dismiss the keyboard.
                textField.text = "1"
                textField.resignFirstResponder()
            }
        }
        dismiss( animated:true, completion:nil )
    }
    
    func numberCellTouched(_ sender: UITapGestureRecognizer) ->() {
        if let textField = sender.view?.viewWithTag(2) {
            textField.becomeFirstResponder()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ sender: UITextField) {
        for (cellLabel, textField) in textFieldMap {
            if( sender == textField ) {
                if let uintVal = UInt(sender.text!) {
                    keyDerivValueMap[cellLabel] = uintVal
                }
            }
        }
    }
    
    func textFieldShouldEndEditing(_ sender: UITextField) -> Bool {
        if let senderText = sender.text {
            if UInt(senderText) != nil {
                // Entered string is an integer.
                 return true
            }
            self.presentAlertWithTitle("Entry Error", message: "Entry must be a whole number")
            return false
        }
        return false
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let selectionViewController = segue.destination as! SelectionViewController
        if (cell.textLabel?.text == encryptionMethodLabel) {
            let isKdb4Index = isKdb4==true ? 1 : 0
            selectionViewController.items = encryptionNames[isKdb4Index]
            selectionViewController.selectedIndex = encryptionNameIndex
            selectionViewController.itemSelected = { (selectedIndex) in
                self.encryptionNameIndex = selectedIndex
                cell.detailTextLabel?.text = self.encryptionNames[isKdb4Index][self.encryptionNameIndex]
                self.navigationController?.popViewController(animated: true)
            }
        } else if (cell.textLabel?.text == keyDerivMethodLabel) {
            selectionViewController.items = keyDerivNamesKdb4
            selectionViewController.selectedIndex = keyDerivNameIndex
            selectionViewController.itemSelected = { [unowned self] (selectedIndex) in
                self.keyDerivNameIndex = selectedIndex
                cell.detailTextLabel!.text = self.keyDerivNamesKdb4[self.keyDerivNameIndex]
                self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            assertionFailure("Unknown segue")
        }
    }

    func loadCellData(_ cellLabel: String) {
        textFieldMap[cellLabel]?.text = "\(keyDerivValueMap[cellLabel]!)"
        
    }
    
    func uuidToEncryptionIndex(_ uuid: KdbUUID) -> Int {
        if( uuid == KdbUUID.getAESUUID() ) {
            return 0;
        } else if( uuid == KdbUUID.getChaCha20() ) {
            return 1;
        } else {
            return 0;
        }
    }

    func setupKeyDerivationValues(_ bytes: Data) -> Int {
        let tree = databaseDocument.kdbTree as? Kdb4Tree
        let uuid = KdbUUID(data: bytes)

        // Setup the default values
        var kdfDefParams: VariantDictionary
        kdfDefParams = KdbPassword.getDefaultKDFParameters(KdbUUID.getAES_KDFUUID())
        let rounds = kdfDefParams[KDF_AES_KEY_ROUNDS] as? NSNumber
        keyDerivValueMap[keyDerivRowLabels[0][0]] = rounds?.uintValue

        kdfDefParams = KdbPassword.getDefaultKDFParameters(KdbUUID.getArgon2())
        let iterations = kdfDefParams[KDF_ARGON2_KEY_ITERATIONS] as? NSNumber
        keyDerivValueMap[keyDerivRowLabels[1][0]] = iterations?.uintValue
        let memory = kdfDefParams[KDF_ARGON2_KEY_MEMORY] as? NSNumber
        keyDerivValueMap[keyDerivRowLabels[1][1]] = (memory?.uintValue)! / (1024*1024)
        let parallelism = kdfDefParams[KDF_ARGON2_KEY_PARALLELISM] as? NSNumber
        keyDerivValueMap[keyDerivRowLabels[1][2]] = parallelism?.uintValue

        // Get the database current values
        if( uuid == KdbUUID.getAES_KDFUUID() ) {
            // Map "Rounds" to the kdfParam NSNumber
            let rounds = tree?.kdfParams[KDF_AES_KEY_ROUNDS] as? NSNumber
            keyDerivValueMap[keyDerivRowLabels[0][0]] = rounds?.uintValue
            return 0;
        } else if( uuid == KdbUUID.getArgon2() ) {
            // Map "Iterations", "Memory", and "Parallelism" to the kdfParam NSNumbers
            let iterations = tree?.kdfParams[KDF_ARGON2_KEY_ITERATIONS] as? NSNumber
            keyDerivValueMap[keyDerivRowLabels[1][0]] = iterations?.uintValue
            let memory = tree?.kdfParams[KDF_ARGON2_KEY_MEMORY] as? NSNumber
            keyDerivValueMap[keyDerivRowLabels[1][1]] = (memory?.uintValue)! / (1024*1024)
            let parallelism = tree?.kdfParams[KDF_ARGON2_KEY_PARALLELISM] as? NSNumber
            keyDerivValueMap[keyDerivRowLabels[1][2]] = parallelism?.uintValue
            return 1;
        } else {
            return 0;
        }
    }

    func changeDatabaseValues() {
        if( !isKdb4 ) {
            let tree = databaseDocument.kdbTree as! Kdb3Tree
            var flags = UInt8(tree.flags)
            if( encryptionNameIndex == 0 ) {
                flags &= ~(UInt8(FLAG_TWOFISH))
                flags |= UInt8(FLAG_RIJNDAEL)
            } else if( encryptionNameIndex == 1 ) {
                flags &= ~(UInt8(FLAG_RIJNDAEL))
                flags |= UInt8(FLAG_TWOFISH)
            }
            tree.flags = UInt32(flags)
            tree.rounds = UInt32( keyDerivValueMap[keyDerivRowLabels[0][0]]! )
        } else {
            let tree = databaseDocument.kdbTree as? Kdb4Tree
            if( encryptionNameIndex == 0 ) {
                tree?.encryptionAlgorithm = KdbUUID.getAESUUID()
            } else if( encryptionNameIndex == 1 ) {
                tree?.encryptionAlgorithm = KdbUUID.getChaCha20()
            }
            
            if( keyDerivNameIndex == 0 ) {
                // Map "Rounds" to the kdfParam NSNumber
                tree?.kdfParams.addByteArray( KdbUUID.getAES_KDFUUID().getData(), forKey:KDF_KEY_UUID_BYTES)
                let rounds = UInt64( keyDerivValueMap[keyDerivRowLabels[0][0]]! )
                tree?.kdfParams.add( rounds, forKey:KDF_AES_KEY_ROUNDS )
            } else if( keyDerivNameIndex == 1 ) {
                // Map "Iterations", "Memory", and "Parallelism" to the kdfParam NSNumbers
                tree?.kdfParams.addByteArray( KdbUUID.getArgon2().getData(), forKey:KDF_KEY_UUID_BYTES)
                let iterations = UInt64( keyDerivValueMap[keyDerivRowLabels[1][0]]! )
                tree?.kdfParams.add( iterations, forKey:KDF_ARGON2_KEY_ITERATIONS )
                let memory = UInt64( keyDerivValueMap[keyDerivRowLabels[1][1]]! )
                tree?.kdfParams.add( memory*1024*1024, forKey:KDF_ARGON2_KEY_MEMORY )
                let parallelism = UInt32( keyDerivValueMap[keyDerivRowLabels[1][2]]! )
                tree?.kdfParams.add( parallelism, forKey:KDF_ARGON2_KEY_PARALLELISM )
            }
        }
    }
}

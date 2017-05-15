/*
 * Copyright 2016 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

class NewDatabaseViewController: UITableViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var versionSegmentedControl: UISegmentedControl!

    var donePressed: ((_ newDatabaseViewController: NewDatabaseViewController, _ url: URL, _ password: String, _ version: Int) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == nameTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            confirmPasswordTextField.becomeFirstResponder()
        } else if (textField == confirmPasswordTextField) {
            donePressedAction(nil)
        }
        return true
    }
    
    // MARK: - Actions

    @IBAction func donePressedAction(_ sender: UIBarButtonItem?) {
        // Check to make sure the name was supplied
        let name = nameTextField.text
        if (name == nil || name!.isEmpty) {
            presentAlertWithTitle(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Database name is required", comment: ""))
            return
        }

        // Check the passwords
        let password1 = passwordTextField.text
        let password2 = confirmPasswordTextField.text
        if (password1 != password2) {
            presentAlertWithTitle(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Passwords do not match", comment: ""))
            return
        }
        if (password1 == nil || password1!.isEmpty) {
            presentAlertWithTitle(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Password is required", comment: ""))
            return
        }

        // Create a URL to the file
        var version: Int
        var url = MiniKeePassAppDelegate.documentsDirectoryUrl()!
        url = url.appendingPathComponent(name!)
        if (versionSegmentedControl.selectedSegmentIndex == 0) {
            version = 1
            url = url.appendingPathExtension("kdb")
        } else {
            version = 2
            url = url.appendingPathExtension("kdbx")
        }

        // Check if the file already exists
        var isReachable: Bool = true
        do {
            isReachable = try url.checkPromisedItemIsReachable()
        } catch {
            isReachable = false;
        }
        
        if( isReachable ) {
            presentAlertWithTitle(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("A file already exists with this name", comment: ""))
            return
        }

        // Notify the listener
        donePressed?(self, url, password1!, version)
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

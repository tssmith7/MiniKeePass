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

import UIKit

class FilesViewController: UITableViewController {
    fileprivate let databaseReuseIdentifier = "DatabaseCell"
    fileprivate let dropboxReuseIdentifier = "DropboxCell"
    fileprivate let keyFileReuseIdentifier = "KeyFileCell"

    fileprivate enum Section : Int {
        case databases = 0
        case keyFiles = 1
        case dropboxFiles = 2

        static let AllValues = [Section.databases, Section.keyFiles, Section.dropboxFiles]
    }

    var databaseFiles: [String] = []
    var keyFiles: [String] = []
    var dropboxFiles: [String] = []
    var dropboxStatus: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let databaseManager = DatabaseManager.sharedInstance() {
            databaseFiles = databaseManager.getDatabases() as! [String]
            keyFiles = databaseManager.getKeyFiles() as! [String]
        }
        if( AppSettings.sharedInstance().dropboxEnabled() ) {
            self.loadDropboxFiles()
        }

        tableView.reloadData()
        
        super.viewWillAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let groupViewController = segue.destination as? GroupViewController else {
            return
        }
        
        let appDelegate = MiniKeePassAppDelegate.getDelegate()
        let document = appDelegate?.databaseDocument
        
        groupViewController.parentGroup = document?.kdbTree.root
        groupViewController.title = URL(fileURLWithPath: document!.filename).lastPathComponent
    }
    
    // MARK: - Empty State

    func toggleEmptyState() {
        if (databaseFiles.count == 0 && keyFiles.count == 0 && dropboxFiles.count == 0 && dropboxStatus == nil ) {
            let emptyStateLabel = UILabel()
            emptyStateLabel.text = NSLocalizedString("Tap the + button to add a new KeePass file.", comment: "")
            emptyStateLabel.textAlignment = .center
            emptyStateLabel.textColor = UIColor.gray
            emptyStateLabel.numberOfLines = 0
            emptyStateLabel.lineBreakMode = .byWordWrapping

            tableView.backgroundView = emptyStateLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    // MARK: - UITableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.AllValues.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section.AllValues[section] {
        case .databases:
            return NSLocalizedString("Databases", comment: "")
        case .keyFiles:
            return NSLocalizedString("Key Files", comment: "")
        case .dropboxFiles:
            return NSLocalizedString("Dropbox", comment: "")
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Hide the section titles if there are no files in a section
        switch Section.AllValues[section] {
        case .databases:
            if (databaseFiles.count == 0) {
                return 0
            }
        case .keyFiles:
            if (keyFiles.count == 0) {
                return 0
            }
        case .dropboxFiles:
            if (dropboxFiles.count == 0 && dropboxStatus == nil) {
                return 0
            }
        }

        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toggleEmptyState()

        switch Section.AllValues[section] {
        case .databases:
            return databaseFiles.count
        case .keyFiles:
            return keyFiles.count
        case .dropboxFiles:
            return dropboxFiles.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section:Int) -> CGFloat {
    
        switch Section.AllValues[section] {
        case .dropboxFiles:
            if( dropboxStatus == nil ) {
                return 0
            }
            let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
            return font.lineHeight + 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch Section.AllValues[section] {
        case .dropboxFiles:
            if( dropboxStatus == nil ) {
                return nil
            }
            let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
            let footer = UILabel()
            footer.font = font;
            footer.textColor = UIColor.red
            footer.backgroundColor = UIColor.clear
            footer.text = "    " + dropboxStatus
            return footer
        default:
            return nil
        }
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let filename: String

        // Get the cell and filename
        switch Section.AllValues[indexPath.section] {
        case .databases:
            cell = tableView.dequeueReusableCell(withIdentifier: databaseReuseIdentifier, for: indexPath)
            filename = databaseFiles[indexPath.row]
        case .keyFiles:
            cell = tableView.dequeueReusableCell(withIdentifier: keyFileReuseIdentifier, for: indexPath)
            filename = keyFiles[indexPath.row]
        case .dropboxFiles:
            cell = tableView.dequeueReusableCell(withIdentifier: dropboxReuseIdentifier, for: indexPath)
            filename = dropboxFiles[indexPath.row]
        }

        cell.textLabel!.text = filename
        
        // Get the file's modification date
        let databaseManager = DatabaseManager.sharedInstance()
        var date: Date?
        if( indexPath.section == Section.databases.rawValue ) {
            // Get the file's last modification time
            let url = databaseManager?.getFileUrl(filename)
            date = databaseManager?.getFileLastModificationDate(url)
        } else {
            let dropboxManager = DropboxManager.sharedInstance()
            date = dropboxManager?.getDropboxFileModifiedDate(filename)
        }
        
        if( date != nil ) {

            // Format the last modified time as the subtitle of the cell
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            cell.detailTextLabel!.text = NSLocalizedString("Last Modified", comment: "") + ": " + dateFormatter.string(from: date!)
        } else {
            cell.detailTextLabel!.text = NSLocalizedString("Last Modified", comment: "") + ": " + "(-)"
        }

        return cell
    }

    // MARK: - UITableView delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section.AllValues[indexPath.section] {
        case .databases:
            // Load the database
            let databaseManager = DatabaseManager.sharedInstance()
            databaseManager?.openDatabaseDocument(databaseFiles[indexPath.row], animated: true, dropbox: false)
            break
        case .dropboxFiles:
            // Download the dropbox database and load
            self.downloadDropboxFile(dropboxFiles[indexPath.row])
            break
        case .keyFiles:
            break
            /* Do nothing */
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.deleteRowAtIndexPath(indexPath)
        }
        
        let renameAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Rename", comment: "")) { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.renameRowAtIndexPath(indexPath)
        }
        
        switch Section.AllValues[indexPath.section] {
        case .databases:
            return [deleteAction, renameAction]
        case .keyFiles:
            return [deleteAction]
        case .dropboxFiles:
            return nil
        }
    }
    
    func renameRowAtIndexPath(_ indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "RenameDatabase", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        let viewController = navigationController.topViewController as! RenameDatabaseViewController
        viewController.donePressed = { (renameDatabaseViewController: RenameDatabaseViewController, originalUrl: URL, newUrl: URL) in

            let databaseManager = DatabaseManager.sharedInstance()
            databaseManager?.renameDatabase(originalUrl, newUrl: newUrl)
            
            // Update the filename in the files list
            self.databaseFiles[indexPath.row] = newUrl.lastPathComponent
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            
            self.dismiss(animated: true, completion: nil)
        }
        
        let databaseManager = DatabaseManager.sharedInstance()
        viewController.originalUrl = databaseManager?.getFileUrl(databaseFiles[indexPath.row])
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func deleteRowAtIndexPath(_ indexPath: IndexPath) {
        // Get the filename to delete
        let filename: String
        switch Section.AllValues[indexPath.section] {
        case .databases:
            filename = databaseFiles.remove(at: indexPath.row)
        case .keyFiles:
            filename = keyFiles.remove(at: indexPath.row)
        case .dropboxFiles:
            return
        }
        
        // Delete the file
        let databaseManager = DatabaseManager.sharedInstance()
        databaseManager?.deleteFile(filename)
       
        // Update the table
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    // MARK: - Actions

    @IBAction func settingsPressed(_ sender: UIBarButtonItem?) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!

        present(viewController, animated: true, completion: nil)
    }

    @IBAction func helpPressed(_ sender: UIBarButtonItem?) {
        let storyboard = UIStoryboard(name: "Help", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!

        present(viewController, animated: true, completion: nil)
    }

    @IBAction func addPressed(_ sender: UIBarButtonItem?) {
        let storyboard = UIStoryboard(name: "NewDatabase", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController

        let viewController = navigationController.topViewController as! NewDatabaseViewController
        viewController.donePressed = { (newDatabaseViewController: NewDatabaseViewController, url: URL, password: String, version: Int) -> Void in
            // Create the new database
            let databaseManager = DatabaseManager.sharedInstance()
            databaseManager?.newDatabase(url, password: password, version: version)
            
            // Add the file to the list of files
            let filename = url.lastPathComponent
            let index = self.databaseFiles.insertionIndexOf(filename) {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
            self.databaseFiles.insert(filename, at: index)
            
            // Notify the table of the new row
            if (self.databaseFiles.count == 1) {
                // Reload the section if it was previously empty
                let indexSet = IndexSet(integer: Section.databases.rawValue)
                self.tableView.reloadSections(indexSet, with: .right)
            } else {
                let indexPath = IndexPath(row: index, section: Section.databases.rawValue)
                self.tableView.insertRows(at: [indexPath], with: .right)
            }

            newDatabaseViewController.dismiss(animated: true, completion: nil)
        }

        present(navigationController, animated: true, completion: nil)
    }
    
    func loadDropboxFilesCallback(_ error: Error? ) -> Void {
        if( error != nil ) {
            print(error!)
            dropboxStatus = error?.localizedDescription
        } else {
            dropboxFiles = DropboxManager.sharedInstance().getDropboxFileList() as! [String]
            if( dropboxFiles.count == 0 ) {
                dropboxStatus = "No Files Found"
            } else {
                dropboxStatus = nil;
            }
        }
        // Update the dropbox file list on the main execution thread...
        DispatchQueue.main.async() { [unowned self] () -> Void in
            self.tableView.reloadData()
        }
    }

    func loadDropboxFiles() {
        dropboxFiles = []
        dropboxStatus = "Loading ...";
        
        // This function returns immediately and then calls the Callback function
        // when the file list has been retrieved from Dropbox.
        DropboxManager.sharedInstance().loadDropboxFileList( loadDropboxFilesCallback )

        // Show loading... status footer
        tableView.reloadData()
    }
    
    func downloadDropboxFile(_ path: String) {
    
        DropboxManager.sharedInstance().downloadDropboxFile(path, requestCallback:{ [unowned self] (error: Error?) -> Void in
            if( error != nil ) {
                print(error!)
                self.dropboxStatus = error?.localizedDescription
                self.tableView.reloadData()
            } else {
                // Load the database
                self.dropboxStatus = nil;
                DatabaseManager.sharedInstance().openDatabaseDocument(path, animated:true, dropbox:true )
            }
        })
    }
}

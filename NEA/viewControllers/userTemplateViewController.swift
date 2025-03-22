//
//  userTemplateViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 22/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase


class userTemplateViewController: UIViewController {
    
    @IBOutlet weak var userTemplateTable: UITableView!
    var exerciseNames: [String] = [] // Array to store the exercise names
    
    let templateVC = templateViewController()

        override func viewDidLoad() {
            super.viewDidLoad()

            // Register your custom cell (if you're not doing it in the storyboard)
            userTemplateTable.register(UINib(nibName: "TemplateTableViewCell" , bundle: nil), forCellReuseIdentifier: "cellReused")
            
            userTemplateTable.dataSource  = self
            fetchTemplateData()
        }

    func fetchTemplateData() {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }
        
        let userID = user.uid
        let username = Auth.auth().currentUser?.email ?? "No username"
        let sanitizedUsername = templateVC.sanitizeString(string: username)
        let userTemplatesRef = Database.database().reference().child("users_templates").child(userID).child(sanitizedUsername).child("template1")
        
        userTemplatesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let templateData = snapshot.value as? [String] {
                self.exerciseNames = templateData
                self.userTemplateTable.reloadData() // Reload the table view to display the fetched data
            } else {
                print("No template data found for this user.")
                self.exerciseNames = [] // Clear the array if no data is found
                self.userTemplateTable.reloadData() // Reload the table view to reflect the empty state
            }
        }
    }

    



}

extension userTemplateViewController: UITableViewDataSource {//datasource tells how many rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseNames.count
    }
    //provides tableview with a cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReused", for: indexPath) as! TemplateTableViewCell
        /*returns a reusable table-view cell object for the specified reuse identifier and adds it to the table*/
        
        let exerciseName = exerciseNames[indexPath.row]
        cell.nameOfExercise.text = exerciseName
        return cell
    }
}

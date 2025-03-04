//
//  progressViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 04/03/2025.
//

import UIKit

class progressViewController: UIViewController {

    @IBOutlet weak var muscleGroupsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        muscleGroupsTable.dataSource = self
        
    }
    
    var muscleGroup: [muscleGroups] = [
        muscleGroups(groupName: "Chest"),
        muscleGroups(groupName: "Back"),
        muscleGroups(groupName: "Shoulders"),
        muscleGroups(groupName: "Arms"),
        muscleGroups(groupName: "Legs"),
        
        
        
    ]
    
  

}


extension progressViewController: UITableViewDataSource {//datasource tells how many rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return muscleGroup.count
    }
    //provides tableview with a cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseableCell", for: indexPath) /*returns a reusable table-view cell object for the specified reuse identifier and adds it to the table*/
        
        cell.textLabel?.text = muscleGroup[indexPath.row].groupName
        return cell
    }
}

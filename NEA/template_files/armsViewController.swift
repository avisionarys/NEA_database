//
//  armsViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 02/03/2025.
//

import UIKit

class armsViewController: UIViewController {
    
    
    @IBOutlet weak var armsTableView: UITableView!
    
    
    var exercises: [exercise] = [
        exercise(name: "shoulder press", muscleArea: "upper body", muscle: "shoulders"),
        exercise(name: "overhand write curl", muscleArea: "forearms", muscle: "forearms"),
        exercise(name:"tricep dips", muscleArea: "upper body", muscle: "triceps")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the exerciseTableView to the extentions
        armsTableView.dataSource = self
      
        armsTableView.register(UINib(nibName: "TemplateTableViewCell" , bundle: nil), forCellReuseIdentifier: "cellReused")
       
        title = "Exercises"
      
        
    }
    
    
    @IBAction func finishedPressed(_ sender: UIButton) {
    }
    
    
    
}

extension armsViewController: UITableViewDataSource {//datasource tells how many rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    //provides tableview with a cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReused", for: indexPath) as!  TemplateTableViewCell
        cell.nameOfExercise.text = exercises[indexPath.row].name//sets the name of the exercise in the cell to the clicked on cell by the user from exerciseViewController
        
        return cell
    }
}

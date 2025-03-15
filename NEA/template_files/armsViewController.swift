//
//  armsViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 02/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase

class armsViewController: UIViewController {
    
    let database = Database.database().reference()
    let templateVC = templateViewController()
    
    @IBOutlet weak var armsTableView: UITableView!
    
    
    var exercises: [exercise] = [
        exercise(name: "shoulder press", muscleArea: "arms", muscle: "shoulders"),
        exercise(name: "overhand wrist curl", muscleArea: "arms", muscle: "forearms"),
        exercise(name:"tricep dips", muscleArea: "arms", muscle: "triceps")
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the exerciseTableView to the extentions
        armsTableView.dataSource = self
      //get the custom cell from the TemplateTableViewCell
        armsTableView.register(UINib(nibName: "TemplateTableViewCell" , bundle: nil), forCellReuseIdentifier: "cellReused")
       
        title = "Arms Workout"

       
    }
   
    
    //create the array full of workoutdata objects
    var dataForExercise: [WorkoutData] = []
    // using dispatchGroup to synchronise tasks
    let dispatchGroup = DispatchGroup()
    // pull and save the data to the database
    @IBAction func finishedPressed(_ sender: UIButton) {
        
        for i in 0..<armsTableView.numberOfRows(inSection: 0) {
            guard let cell = armsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? TemplateTableViewCell else { continue }
            let exerciseName = cell.nameOfExercise.text ?? ""
            let weight = cell.weightTextField.text ?? ""
            let reps = cell.repsTextField.text ?? ""
            var muscleGroup:String? = nil
            // starts the synchronization of getting the muscleGroup and creating workout objects
            dispatchGroup.enter()
            
            templateVC.getMuscleForExercise(exerciseName: exerciseName) { muscle in
                if let muscle = muscle {
                    muscleGroup = muscle
                } else {
                    print("Could not retrieve muscle information.")
                }
                
                // Create the workout data object
                let workoutData = WorkoutData(exerciseName: exerciseName, weight: weight, reps: reps, muscleGroup: muscleGroup ?? "nil")
                self.dataForExercise.append(workoutData)
                
                // Leave the dispatch group after it has completed
                self.dispatchGroup.leave()
            }
        }
        //this will run after all the tasks above have finished
        dispatchGroup.notify(queue: .main) {
            do {
                // Attempt to save to Firebase
                try self.templateVC.saveToFirebase(data: self.dataForExercise)

                // Navigate to the home view controller if successful
                if let viewControllers = self.navigationController?.viewControllers {
                    for viewController in viewControllers {
                        if viewController is homeViewController {
                            self.navigationController?.popToViewController(viewController, animated: true)
                            return
                        }
                    }
                }
            } catch {
                // Handle the error appropriately
                print("Error saving data: \(error.localizedDescription)")
            }
        }
        
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
        let theName = cell.nameOfExercise.text ?? "No text"
        self.templateVC.getMaxWeight(name: theName) { weightLabel in // calls the function to get the weight for that exercise
            if let weightLabel = weightLabel {
                print("Label: \(weightLabel)")
                cell.recordWeight.text = weightLabel//sets the weight
            } else {
                print("Failed to fetch the label.")//if unable , will print error
            }
        }
        
        templateVC.findMostRecentExerciseData(for: theName) { result in
            switch result {
            case .success(let data):
                // Store weight and reps as constants
                let mostRecentWeight = data.weight
                let mostRecentReps = data.reps

                
                print("Most recent weight for \(theName): \(mostRecentWeight)")
                print("Most recent reps for \(theName): \(mostRecentReps)")
                // sets the labels in the tableView to theeir specific values
                cell.previousWeight.text = mostRecentWeight
                cell.previousReps.text = mostRecentReps

            case .failure(let error):
                // Handles the error
                print("Error fetching most recent exercise data: \(error.localizedDescription)")
            }
        }
        
        return cell
    }
}


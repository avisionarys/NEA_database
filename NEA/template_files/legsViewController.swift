//
//  legsViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 15/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase


class legsViewController: UIViewController {
    
    let database = Database.database().reference()
    let templateVC = templateViewController()
    
    
    @IBOutlet weak var legsTableView: UITableView!
    
    var exercises: [exercise] = [
        exercise(name: "lying leg curls", muscleArea: "lowerBody", muscle: "hamstring"),
        exercise(name: "calve press",muscleArea: "lower body", muscle: "calves"),
        exercise(name:"leg extentions", muscleArea: "lower body", muscle: "quads")
        
    ]
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the exerciseTableView to the extentions
        legsTableView.dataSource = self
      //get the custom cell from the TemplateTableViewCell
        legsTableView.register(UINib(nibName: "TemplateTableViewCell" , bundle: nil), forCellReuseIdentifier: "cellReused")
       
        title = "legs Workout"


      
    }
    //create the array full of workoutdata objects
    var dataForExercise: [WorkoutData] = []
    // using dispatchGroup to synchronise tasks
    let dispatchGroup = DispatchGroup()
    // pull and save the data to the database
    @IBAction func finishedPressed(_ sender: UIButton) {
        
        for i in 0..<legsTableView.numberOfRows(inSection: 0) {
            guard let cell = legsTableView.cellForRow(at: IndexPath(row: i, section: 0)) as? TemplateTableViewCell else { continue }
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




extension legsViewController: UITableViewDataSource {//datasource tells how many rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    //provides tableview with a cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReused", for: indexPath) as!  TemplateTableViewCell
        cell.nameOfExercise.text = exercises[indexPath.row].name//sets the name of the exercise in the cell to the clicked on cell by the user from exerciseViewController
        let exerciseNameLabel = cell.nameOfExercise.text ?? "No text"
        //calls the function and displays the personal record for user
        templateVC.findMaxExerciseWeight(for: exerciseNameLabel) { result in
            switch result {
            case .success(let maxWeight):
                print("Max \(exerciseNameLabel) weight: \(maxWeight)")
                let weightLabel = "\(maxWeight)"
                cell.recordWeight.text = weightLabel
            case .failure(let error):
                print("Error fetching max weight: \(error)")
            }
        }
        //calls the function from the TemplateTableViewController and pulls the previous values
        templateVC.findMostRecentExerciseData(for: exerciseNameLabel) { result in
            switch result {
            case .success(let data):
                // Store weight and reps as constants
                let mostRecentWeight = data.weight
                let mostRecentReps = data.reps
                print("Most recent weight for \(exerciseNameLabel): \(mostRecentWeight)")
                print("Most recent reps for \(exerciseNameLabel): \(mostRecentReps)")
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

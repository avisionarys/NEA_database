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
    //defined a variable to store the name of the template
    var usersTemplate: String?
    
    @IBOutlet weak var userTemplateTable: UITableView!
    var exerciseNames: [String] = [] // Array to store the exercise names
    
    let templateVC = templateViewController()

    @IBOutlet weak var usertemplateTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTemplateTable.register(UINib(nibName: "TemplateTableViewCell" , bundle: nil), forCellReuseIdentifier: "cellReused")
        
        userTemplateTable.dataSource  = self
        //sets the constant passed through to the variable above so it can be passed as a paramter in the function
        if let passedTemplateName = usersTemplate{
            print("selected template is \(passedTemplateName)")
            fetchTemplateData(templateName:passedTemplateName)
            
        }
        
        title  = usersTemplate
        
    }
    
    

    func fetchTemplateData(templateName:String? = nil) {
        guard let user = Auth.auth().currentUser else {
            print("User not authenticated.")
            return
        }
        
        let userID = user.uid
        let username = Auth.auth().currentUser?.email ?? "No username"
        let sanitizedUsername = templateVC.sanitizeString(string: username)
        let userTemplatesRef = Database.database().reference().child("users_templates").child(userID).child(sanitizedUsername).child(templateName ?? "")
        
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
    
    //create the array full of workoutdata objects
    var dataForExercise: [WorkoutData] = []
    // using dispatchGroup to synchronise tasks
    let dispatchGroup = DispatchGroup()
    // pull and save the data to the databas
    @IBAction func saveWorkout(_ sender: Any) {
        for i in 0..<usertemplateTable.numberOfRows(inSection: 0) {
            guard let cell = usertemplateTable.cellForRow(at: IndexPath(row: i, section: 0)) as? TemplateTableViewCell else { continue }
            let exerciseName = cell.nameOfExercise.text ?? ""
            let weight = cell.weightTextField.text ?? ""
            let reps = cell.repsTextField.text ?? ""
            
            //checks if any textfields are empty first
            if exerciseName.isEmpty || weight.isEmpty || reps.isEmpty {
                print("One or more text fields are empty. Please fill them out.")
                return
            }
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

//
//  templateViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 09/02/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase

//creating a struct for the data
struct WorkoutData: Codable, Identifiable {
    @DocumentID var id: String?
    let exerciseName: String
    let weight: String
    let reps: String
    let muscleGroup: String
}


class templateViewController: UIViewController, UITableViewDelegate , MyProtocol{
    
    
    
    
    private let db = Firestore.firestore()
    let database = Database.database().reference()
    @IBOutlet weak var tableView: UITableView!
    
    var Workouts: [String] = []
    //change the screen using the seg called "segues "
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segues" {
            if let secondVC = segue.destination as? exercisesViewController {
                secondVC.delegate = self
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseTableView.dataSource = self
        exerciseTableView.delegate = self
        
        tableView.register(UINib(nibName: "TemplateTableViewCell" , bundle: nil), forCellReuseIdentifier: "cellReused")
        
        
        
    }
    
    
    
    func addExercise(workout: String){
        Workouts.append(workout)
        exerciseTableView.reloadData()
    }
    
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    func sanitizeString(string: String) -> String {
        let sanitizedString = string.replacingOccurrences(of: "[.#$\\[\\]]", with: "_", options: .regularExpression)
        return sanitizedString
    }
    
    
    
    var dataForExercise: [WorkoutData] = []
    
    @IBAction func saveWorkoutData(_ sender: UIBarButtonItem) {
        
        
        
        
        
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? TemplateTableViewCell else { continue }
            let exerciseName = cell.nameOfExercise.text ?? ""
            let weight = cell.weightTextField.text ?? ""
            let reps = cell.repsTextField.text ?? ""
            let muscleGroup = "chest"
            
            let workoutData = WorkoutData(exerciseName: exerciseName, weight: weight, reps: reps, muscleGroup: muscleGroup)
            dataForExercise.append(workoutData)
            
            
        }
        
        saveToFirebse(data: dataForExercise)
        
        
        //the code for the fucntion that will take the data and save it to firebase
        
        func saveToFirebse(data: [WorkoutData]) {
            //checks user signed in and defines constants//
            if let user = Auth.auth().currentUser {
                let userID = user.uid
                let workoutID  = UUID().uuidString
                let username = Auth.auth().currentUser?.email ?? "No username"
                
                let sanitizedUsername = sanitizeString(string:username)
                
                //starts creating the nodes in hirarchial structure//
                
                let workoutRef = database.child("users_data").child(userID).child(sanitizedUsername).child(workoutID)
                //loops through each workoutData object in the dataforexercise array
                for workoutData in data {
                    
                    let workoutDataDictionary = workoutData.toDictionary()//converts data to dictionary format//
                    
                    //saves the data to firebase under the exercises  node//
                    workoutRef.child("exercises").child(workoutData.exerciseName).setValue(workoutDataDictionary) { error, _ in
                        if let error = error {   //error handling //
                            print("Error saving workout data: \(error)")
                        } else {
                            print("Workout data saved successfully")
                            //changes screen back to homescreen//
                            if let viewControllers = self.navigationController?.viewControllers {
                                for viewController in viewControllers {
                                    if viewController is homeViewController {
                                        self.navigationController?.popToViewController(viewController, animated: true)
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("No user signed in")
            }
        }
        
        
    }
    
 

    // finding the maximum wieght for the bench press exercise as first iteration //
    func findMaxBenchPressWeight(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { // chekcs user authentication, guard = readability
            completion(.failure(NSError(domain: "User not authenticated", code: 0, userInfo: nil)))
            return
        }
        let userID = user.uid//defining constants so that the correct location can be recalled//
        let username = Auth.auth().currentUser?.email ?? "No username"
        let sanitizedUsername = sanitizeString(string: username)
        //referances data//
        let usersDataRef = database.child("users_data").child(userID).child(sanitizedUsername)
        /*retrieves the users workout data using the observesinglevent by accessing childnodes
         and converting them into an array of ojbjects*/
        usersDataRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let workoutsSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError(domain: "Invalid data format", code: 0, userInfo: nil)))
                return
            }
            //defines the array
            var benchPressWeights: [Double] = []
            //iterates through the users workout data to find all instances of bench press //
            for workoutSnapshot in workoutsSnapshot {
                guard let workoutData = workoutSnapshot.value as? [String: Any],
                      let exercises = workoutData["exercises"] as? [String: Any] else {
                    continue
                }
                //takes the weight for each bench press exercise, checks if a string or double and converts to double to check the maximum one//
                for (exerciseName, exerciseData) in exercises {
                    if exerciseName == "bench press" {
                        // Cast exerciseData to [String: Any] before subscripting
                        if let exerciseDetails = exerciseData as? [String: Any] {
                            if let weight = exerciseDetails["weight"] as? Double {
                                benchPressWeights.append(weight)
                            } else if let weightString = exerciseDetails["weight"] as? String,
                                      let weight = Double(weightString) {
                                benchPressWeights.append(weight)
                            } else {
                                print("Warning: 'weight' key not found or not a number for bench press.")
                            }
                        } else {
                            print("Warning: 'exerciseData' is not a dictionary for bench press.")
                        }
                    }
                }
            }
            //hanldes situation if the array is empty //
            if benchPressWeights.isEmpty {
                completion(.success(0.0))
            } else {
                let maxWeight = benchPressWeights.max()!
                completion(.success(maxWeight))
            }
        }) { error in
            // Handle any errors that occur during the observation
            completion(.failure(error))
        }
    }

    @IBAction func actionaction(_ sender: UIButton) {
        findMaxBenchPressWeight { result in
            switch result {
            case .success(let maxWeight):
                print("Max bench press weight: \(maxWeight)")
            case .failure(let error):
                print("Error fetching max weight: \(error)")
            }
        }
    }

}
    
    
    
    

extension templateViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return Workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReused", for: indexPath) as!  TemplateTableViewCell
        cell.nameOfExercise.text = Workouts[indexPath.row]
        
        /*printing = String("Cell \(indexPath.row): nameOfExercise.text = \(cell.nameOfExercise.text ?? "No text"), weight = \(cell.weightTextField.text ?? "No text"). reps \(cell.repsTextField.text ?? "No text")") */
        
        return cell
    }
    
    
}
//creating the dictionary for the workout data
extension WorkoutData {
    func toDictionary() -> [String: Any] {
        return [
            "exerciseName": exerciseName,
            "weight": weight,
            "reps": reps,
            "muscleGroup": muscleGroup
        ]
    }
}


    


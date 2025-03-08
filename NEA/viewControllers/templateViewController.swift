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
    
    func recallMuscleGroup(for exerciseName: String, completion: @escaping (String?) -> Void) {
            database.child("exercises").child(exerciseName).observeSingleEvent(of: .value) { snapshot in
                if let value = snapshot.value as? [String: Any] {
                    if let muscleArea = value["muscleArea"] as? String,
                       let muscle = value["muscle"] as? String {
                        print("Exercise: \(exerciseName)")
                        print("Muscle Area: \(muscleArea)")
                        print("Muscle: \(muscle)")
                        completion(muscle) // Return the muscle via completion handler
                    } else {
                        print("Error retrieving details for \(exerciseName).")
                        completion(nil) // Return nil if muscle details are missing
                    }
                } else {
                    print("No data found for exercise: \(exerciseName)")
                    completion(nil) // Return nil if no data is found
                }
            } withCancel: { error in
                print("Error fetching data: \(error.localizedDescription)")
                completion(nil) // Return nil on error
            }
    }
    
    func getMuscleForExercise(exerciseName: String, completion: @escaping (String?) -> Void) {
        recallMuscleGroup(for: exerciseName) { muscle in
            completion(muscle)
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
    
    func saveToFirebase(data: [WorkoutData]) {
            // Check if user is signed in
            if let user = Auth.auth().currentUser {
                let userID = user.uid
                let workoutID = UUID().uuidString
                let username = Auth.auth().currentUser?.email ?? "No username"
                let sanitizedUsername = sanitizeString(string: username)
                //finding the date and setting it to a constant
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: Date())
             

                // Create a reference to the Firebase node
                let workoutRef = database.child("users_data").child(userID).child(sanitizedUsername).child(dateString).child(workoutID)

                // Loop through each workout data object
                for workoutData in data {
                    let workoutDataDictionary = workoutData.toDictionary()

                    // Save the data to Firebase
                    workoutRef.child("exercises").child(workoutData.exerciseName).setValue(workoutDataDictionary) { error, _ in
                        if let error = error {
                            print("Error saving workout data: \(error)")
                        } else {
                            print("Workout data saved successfully")

                            // Navigate back to the home screen
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


    
    
    
    var dataForExercise: [WorkoutData] = []
    let dispatchGroup = DispatchGroup()

    @IBAction func saveWorkoutData(_ sender: UIBarButtonItem) {
        
        for i in 0..<tableView.numberOfRows(inSection: 0) {
            guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? TemplateTableViewCell else { continue }
            let exerciseName = cell.nameOfExercise.text ?? ""
            let weight = cell.weightTextField.text ?? ""
            let reps = cell.repsTextField.text ?? ""
            var muscleGroup:String? = nil
            
            dispatchGroup.enter()

                    getMuscleForExercise(exerciseName: exerciseName) { muscle in
                        if let muscle = muscle {
                            muscleGroup = muscle
                        } else {
                            print("Could not retrieve muscle information.")
                        }

                        // Create the workout data object
                        let workoutData = WorkoutData(exerciseName: exerciseName, weight: weight, reps: reps, muscleGroup: muscleGroup ?? "nil")
                        self.dataForExercise.append(workoutData)

                        // Leave the dispatch group after the async task is complete
                        self.dispatchGroup.leave()
                    }
                }

                // Notify when all tasks in the dispatch group are complete
                dispatchGroup.notify(queue: .main) {
                    // Save to Firebase after all async tasks are done
                    self.saveToFirebase(data: self.dataForExercise)
                }
        
        }
    
 

    // finding the max weight for each exercise //
    func findMaxExerciseWeight(for nameOfExercise: String, completion: @escaping (Result<Double, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { // checks user authentication, guard = readability
            completion(.failure(NSError(domain: "User not authenticated", code: 0, userInfo: nil)))
            return
        }
        let userID = user.uid // defining constants so that the correct location can be recalled
        let username = Auth.auth().currentUser?.email ?? "No username"
        let sanitizedUsername = sanitizeString(string: username)
        // references data
        let usersDataRef = database.child("users_data").child(userID).child(sanitizedUsername)
        /* retrieves the user's dates containing workout data using the observeSingleEvent by accessing child nodes
         and converting them into an array of objects */
        usersDataRef.observeSingleEvent(of: .value,with: { snapshot in
                guard let datesSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                    completion(.failure(NSError(domain: "Invalid data format: No dates found", code: 0, userInfo: nil)))
                    return
                }
                //defines the array
                var exerciseWeights: [Double] = []
                //iterates through each date stored in the datessnapshot
                for dateSnapshot in datesSnapshot {
                    guard let workoutsSnapshot = dateSnapshot.children.allObjects as? [DataSnapshot] else {
                        continue// this retrives all the wokrouts under each date
                    }
                    // iterates through the user's workout data to find all instances of the specified exercise
                    for workoutSnapshot in workoutsSnapshot {
                        guard let workoutData = workoutSnapshot.value as? [String: Any],
                              let exercises = workoutData["exercises"] as? [String: Any] else {
                            continue
                        }
                        // takes the weight for each specific exercise, checks if a string or double and converts to a double to check the maximunm one
                        for (exerciseName, exerciseData) in exercises {
                            if exerciseName == nameOfExercise {
                                if let exerciseDetails = exerciseData as? [String: Any],
                                   let weight = exerciseDetails["weight"] as? Double {
                                    exerciseWeights.append(weight)
                                } else if let exerciseDetails = exerciseData as? [String: Any],
                                         let weightString = exerciseDetails["weight"] as? String,
                                         let weight = Double(weightString) {
                                    exerciseWeights.append(weight)
                                } else {
                                    print("Warning: 'weight' key not found or not a number for \(nameOfExercise).")
                                }
                            }
                        }
                    }
                }
                //handles the situation if the array is empty
                if exerciseWeights.isEmpty {
                    completion(.success(0.0))
                } else {
                    let maxWeight = exerciseWeights.max()!
                    completion(.success(maxWeight))
                }
            }){ error in
                //handles any errros that occur during the observation 
                completion(.failure(error))
            }
        }
    

    func getMaxWeight(name: String, completion: @escaping (String?) -> Void) {
        //sets the constant to be pulled as the parameter
        let nameOfExercise = name
        //switch statement so that if and error, it will display it
        findMaxExerciseWeight(for: nameOfExercise) { result in
            switch result {
            case .success(let maxWeight):
                print("Max \(nameOfExercise) weight: \(maxWeight)")
                let weightLabel = "\(maxWeight)"
                completion(weightLabel) // Return the label using the completion handler//
            case .failure(let error):
                print("Error fetching max weight: \(error)")
                completion(nil)
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
        cell.nameOfExercise.text = Workouts[indexPath.row]//sets the name of the exercise in the cell to the clicked on cell by the user from exerciseViewController
        let theName = cell.nameOfExercise.text ?? "No text"
        getMaxWeight(name: theName) { weightLabel in // calls the function to get the weight for that exercise
            if let weightLabel = weightLabel {
                print("maxweight: \(weightLabel)")
                cell.previousWeight.text = weightLabel//sets the weight
            } else {
                print("Failed to fetch the label.")//if unable , will print error
            }
        }
        
        return cell
        /*printing = String("Cell \(indexPath.row): nameOfExercise.text = \(cell.nameOfExercise.text ?? "No text"), weight = \(cell.weightTextField.text ?? "No text"). reps \(cell.repsTextField.text ?? "No text")") */
        
        
    }
    
    
}



    


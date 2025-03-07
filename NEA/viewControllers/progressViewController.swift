//
//  progressViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 04/03/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase

class progressViewController: UIViewController {
    
    @IBOutlet weak var muscleGroupsTable: UITableView!
    let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        muscleGroupsTable.dataSource = self
        //hides the back button back to the register/login screen set by the navigation controller
        navigationItem.hidesBackButton = true
        
        
        
    }
    //created a function for the segmented controll
    @IBAction func segmentedPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 2://when the workout segmeent is pressed the screen changes back to the homescreen
            if let viewControllers = self.navigationController?.viewControllers {
                for viewController in viewControllers {
                    if viewController is homeViewController {
                        self.navigationController?.popToViewController(viewController, animated: true)
                        return
                    }
                }
            }
            //if not pressed then the default is to break out switch statement
        default:
            break
        }
        
        
        
        
    }
    
    
    
    
    
    var muscleGroup: [muscleGroups] = [
        muscleGroups(groupName: "Chest"),
        muscleGroups(groupName:"back"),
        muscleGroups(groupName:"hamstring"),
        muscleGroups(groupName: "calves"),
        muscleGroups(groupName: "quads"),
        muscleGroups(groupName: "neck"),
        muscleGroups(groupName:"abs"),
        muscleGroups(groupName:"shoulders"),
        muscleGroups(groupName: "forearms"),
        muscleGroups(groupName:"triceps")
        
    ]
    
    func sanitizeString(string: String) -> String {
        let sanitizedString = string.replacingOccurrences(of: "[.#$\\[\\]]", with: "_", options: .regularExpression)
        return sanitizedString
    }
    
    
    //defines the object to format the date in yyyy-mm-dd
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    

    //creates a funciton that will return the muscleGroups trained in a week
    func findMuscleGroupsForWeek(completion: @escaping (Result<[String], Error>) -> Void) {//passes in completion handler
        guard let user = Auth.auth().currentUser else {//recives currently signed in user
            completion(.failure(NSError(domain: "User not authenticated", code: 0, userInfo: nil)))
            return
        }
        //defines the constants that are going to be used to retrieve the data
        let userID = user.uid
        let username = Auth.auth().currentUser?.email ?? "No username"
        let sanitizedUsername = sanitizeString(string: username)

        let usersDataRef = database.child("users_data").child(userID).child(sanitizedUsername)
        //gets the date and time and finds 7 days ago
        let currentDate = Date()
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: currentDate)! // Calculate date 7 days ago
        //retrives all the data from the users_data
        usersDataRef.observeSingleEvent(of: .value,with: { snapshot in
            var muscleGroups: Set<String> = [] // defines the array the muscleGroups will be added to
            //checks the data is formated as an array of dataSnapshot objects
            guard let datesSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.failure(NSError(domain: "Invalid data format, so no dates found", code: 0, userInfo: nil)))
                return
            }
            // loops through each date and checks if within a week and checks they are all objects
            for dateSnapshot in datesSnapshot {
                let dateString = dateSnapshot.key // Assuming date is the key
                guard let date = self.dateFormatter.date(from: dateString),
                      date >= oneWeekAgo else { continue } // Check if date is within the last week


                guard let workoutsSnapshot = dateSnapshot.children.allObjects as? [DataSnapshot] else {
                    continue
                }
                // loops through each workout and exercise, adds the muscleGroup to the array
                for workoutSnapshot in workoutsSnapshot {
                    guard let workoutData = workoutSnapshot.value as? [String: Any],
                          let exercises = workoutData["exercises"] as? [String: Any] else {
                        continue
                    }
                    
                    for (_, exerciseData) in exercises {
                        if let exerciseDetails = exerciseData as? [String: Any],
                           let muscleGroup = exerciseDetails["muscleGroup"] as? String {
                            muscleGroups.insert(muscleGroup)
                        } else {
                            print("Warning: 'muscleGroup' key not found or not a string for an exercise.")
                        }
                    }
                }
            }
            //if no errrors the completion handler calls success, if not failure
            completion(.success(Array(muscleGroups)))
        }) { error in
            completion(.failure(error))
        }
    }

  
   









    //test the function of the code above
    @IBAction func buttonAction(_ sender: UIButton) {
        findMuscleGroupsForWeek { result in
            switch result {
            case .success(let muscleGroups):
                //prinst out the muscleGroups if no errors
                DispatchQueue.main.async {
                    print("Muscle groups worked this week: \(muscleGroups)")
                    
                }

            case .failure(let error):
                // Handles error
                DispatchQueue.main.async {
                    print("Error fetching muscle groups: \(error)")
             
                }
            }
        }
        
        
        
        
    }
        
        
        
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

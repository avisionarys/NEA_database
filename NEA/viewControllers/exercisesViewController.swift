//
//  exercisesViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 02/02/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase


protocol selectExercise{
    
    func addExercise(workout: String)
}


class exercisesViewController: UIViewController {

    /*var delegate: AddexerciseDelegate?*/
    var delegate: selectExercise?
    var selectedWorkout: String?
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    let database  = Database.database().reference()
    
    var exercises: [exercise] = [
        exercise(name: "bench press",muscleArea:"upperBody",muscle: "chest"),
        exercise(name: "bent over rows",muscleArea:"upperBody",muscle: "back"),
        exercise(name: "lying leg curls", muscleArea: "lowerBody", muscle: "hamstring"),
        exercise(name: "calf press",muscleArea: "lower body", muscle: "calves"),
        exercise(name:"leg extentions", muscleArea: "lower body", muscle: "quads"),
        exercise(name: "neck curl", muscleArea: "upper body", muscle: "neck"),
        exercise(name: "cable crunch", muscleArea: "upper body", muscle: "abs"),
        exercise(name: "shoulder press", muscleArea: "arms", muscle: "shoulders"),
        exercise(name: "overhand wrist curl", muscleArea: "arms ", muscle: "forearms"),
        exercise(name:"tricep dips", muscleArea: "arms", muscle: "triceps")
    ]
    
    func saveExercises(){
        var exercisesDictionary: [String: Any] = [:]
        for exercise in exercises {
            exercisesDictionary[exercise.name] = [
                "muscleArea": exercise.muscleArea,
                "muscle": exercise.muscle
            ]
        }
        
        database.child("exercises").setValue(exercisesDictionary) { error, _ in
            if let error = error {
                print("Error saving data: \(error.localizedDescription)")
            } else {
                print("Data saved successfully!")
            }
        }
    }

   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the exerciseTableView to the extentions
        exerciseTableView.dataSource = self
        exerciseTableView.delegate = self
        //saveExercises()
        title = "Exercises"
    }
    
   

    

}

//declares extension of the exercisesviewcontroller
extension exercisesViewController: UITableViewDataSource {//datasource tells how many rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    //provides tableview with a cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseableCell", for: indexPath) /*returns a reusable table-view cell object for the specified reuse identifier and adds it to the table*/
        
        cell.textLabel?.text = exercises[indexPath.row].name
        return cell
    }
}
//extention that managaes uitableViewDelegate which manages section highlighs
extension exercisesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)//gives the row the user selected an animation
        
        
        
       //name of exercise retrived and stored in constant
        let exerciseName = exercises[indexPath.row].name
        // uses delegate pattern to call the method and pass the name
        delegate?.addExercise(workout: exerciseName)
       
        //reverts back to previous viewcontrolelr
        dismiss(animated: true)
        
        
        
        

    }
    
    
 }



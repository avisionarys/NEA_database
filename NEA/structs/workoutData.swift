//
//  workoutData.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 04/03/2025.
//

import Foundation
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

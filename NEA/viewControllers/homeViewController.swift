//
//  homeViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 24/01/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FirebaseDatabase

class homeViewController: UIViewController {
    //define variables to connect to the interface builder
    @IBOutlet weak var segmentOutlet: UISegmentedControl!
    
    @IBOutlet weak var myTemplatesUIView: UIView!
    @IBOutlet weak var providedTemplatesUIView: UIView!
    
    
    @IBOutlet weak var myTemplatesTableView: UITableView!
    
    @IBOutlet weak var armsWorkout: UIButton!
    
   
    @IBOutlet var homeViewSeg: UISegmentedControl!
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide the backbutton that was inialsied by the navigation controller
        navigationItem.hidesBackButton = true
        
        //define constahts and make the UIviews display on the screen
        if let myTemplatesView = myTemplatesUIView, let providedTemplatesView = providedTemplatesUIView {
            self.view.bringSubviewToFront(myTemplatesView)
            self.view.bringSubviewToFront(providedTemplatesView)
            myTemplatesUIView.isHidden = true//defines which view is shown when the user enters the homescreen
            providedTemplatesUIView.isHidden = false
        } else {
            print("values are nil")
        }
       
    }
    
    
    
    
    // runs after the view has appeard for the user
    override func viewDidAppear(_ animated: Bool) {
        homeViewSeg?.selectedSegmentIndex = 2// sets the segment back to the workout segment
    }

    //switch statement connected to segmented controller
    @IBAction func SegmentedControll(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{//if the user clicks on provided routines
        case 0:
            providedTemplatesUIView.isHidden = false
            myTemplatesUIView.isHidden = true
        case 1://if user clicks on templates
            providedTemplatesUIView.isHidden = true
            myTemplatesUIView.isHidden = false
            
            //the app will defult to the user being on the provided routines page
        default:
            providedTemplatesUIView.isHidden = false
            myTemplatesUIView.isHidden = true
        }
        
        
        
        
    }
    
    //allow the user to logout of their account
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {    //try statement allows for error handling
            try Auth.auth().signOut()//onces singed out, taken back to register/login page
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {//gets error and displays it 
            print("Error signing out: %@", signOutError)
        }
        
            
        
    }
    

    @IBAction func startWorkoutPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "startWorkout", sender: self)
        
    }
    
    
    @IBAction func armWorkoutPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "armsSeg", sender: self)
        
        
    }
    
    
    @IBAction func homeSegPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            self.performSegue(withIdentifier: "seeProgressSeg", sender: self )
        default:
            break
        }
        
        
        
    }
    
  
    
    
    
}
     


    


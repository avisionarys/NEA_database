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
    
   
    @IBOutlet weak var userTemplatesTable: UITableView?
    
    let database = Database.database().reference()
    
    let templateVC = templateViewController()
    
 //sends the constant through and sets it to usersTemplate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userTemplateSegue" {
            if let userTemplatesVC = segue.destination as? userTemplateViewController {
                if let templateName = sender as? String { // Retrieve the passed name
                    userTemplatesVC.usersTemplate = templateName
                }
            }
        }
    }
    
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTemplatesTable?.dataSource = self
        userTemplatesTable?.delegate = self
        

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
        //call the function to get the names in after the view loads
        getTemplateNames()
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
    
    @IBAction func legWorkoutPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "legsSeg", sender: self)
        
        
    }
    
    
    @IBAction func homeSegPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            self.performSegue(withIdentifier: "seeProgressSeg", sender: self )
        default:
            break
        }
        
        
        
    }
    
    var templateNames: [String] = []
    //getting the nanes of the templates the user has creaeted
    func getTemplateNames() {
        guard let user = Auth.auth().currentUser else {//getting current user
            print("User not authenticated.")
            return}
        //creating constants for databse referance
        let userID = user.uid
        let username = Auth.auth().currentUser?.email ?? "No username"
        let sanitizedUsername = templateVC.sanitizeString(string: username)
        
        let userTemplatesRef = database.child("users_templates").child(userID).child(sanitizedUsername)
        //pulling all the naames from the realtime database and storing them in an array
        userTemplatesRef.observeSingleEvent(of: .value,with: { (snapshot) in
            if let templates = snapshot.value as? [String: [String]] {
                // Iterate through the templates and store the names and data
                for templateName in templates {
                    print("Template Name: \(templateName)")
                }
                self.templateNames = Array(templates.keys)
                self.userTemplatesTable?.reloadData() // Reloads the table view to display the data
            } else {
                print("No template data found for this user.")
            }
        }) { error in //error handling
            print("Failed to retrieve template data.")
        }
    }
                                            
                                    
  
    
    
    
}

extension homeViewController: UITableViewDataSource {//datasource tells how many rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateNames.count
    }
    //provides tableview with a cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "templateCelllReused", for: indexPath) /*returns a reusable table-view cell object for the specified reuse identifier and adds it to the table*/
        
        cell.textLabel?.text = templateNames[indexPath.row]
        return cell
    }
}

extension homeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)//gives the row the user selected an animation
   
       //name of the template selected stored in the constant templateName
        let templateName = templateNames[indexPath.row]
        
        print(templateName)
        
        //sends the user to the userTemplateViewController witht the constant passing through as well
        self.performSegue(withIdentifier: "userTemplateSegue", sender: templateName)
        
        
        
        
        

    }
    
    
 }


    


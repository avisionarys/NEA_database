//
//  armsViewController.swift
//  NEA
//
//  Created by CHETAN VISROLIA on 02/03/2025.
//

import UIKit

class armsViewController: UIViewController {
    
    let setButton = UIButton(type: .system)

        override func viewDidLoad() {
            super.viewDidLoad()

            // Set the button properties
            setButton.setTitle("Set", for: .normal)
            setButton.addTarget(self, action: #selector(setButtonTapped), for: .touchUpInside)

            // Set button frame or constraints
            setButton.frame = CGRect(x: 100, y: 100, width: 100, height: 50) // Adjust as needed

            // Add the button to the view
            view.addSubview(setButton)
        }

        // Action method for button tap
        @objc func setButtonTapped() {
            // Handle the button tap
            print("Set button tapped!")
        }
    
}

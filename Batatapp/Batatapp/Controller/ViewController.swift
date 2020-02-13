//
//  ViewController.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 13/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var scene: Scene {
        return arView.scene
    }
    var session: ARSession {
        return arView.session
    }

    let coachingOverlay = ARCoachingOverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoachingOverlay()
    }
}

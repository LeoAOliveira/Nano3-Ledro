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
    private var scene: Scene {
        return arView.scene
    }
    private var session: ARSession {
        return arView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

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
import MultipeerConnectivity

class ViewController: UIViewController {

    lazy var multipeerManager: MultipeerManager = MultipeerManager(serviceType: "potatoBomb", handler: self)
    public var player: Player?

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

        _ = multipeerManager
        setupCoachingOverlay()
        configureSession()

        session.delegate = self

        UIApplication.shared.isIdleTimerDisabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(gesture)
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {

    }
}


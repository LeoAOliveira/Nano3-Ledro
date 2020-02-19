//
//  ViewController.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 13/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import MultipeerConnectivity
import Combine

class ViewController: UIViewController {

    lazy var multipeerManager: MultipeerManager = MultipeerManager(serviceType: "potatoBomb", handler: self)
    public var player: Player?

    @IBOutlet var scnView: ARSCNView!
    var scene: SCNScene {
        return scnView.scene
    }
    var session: ARSession {
        return scnView.session
    }

    var potato: SCNNode?

    let coachingOverlay = ARCoachingOverlayView()
    var trackingState: ARCamera.TrackingState = .notAvailable {
        willSet {
            switch newValue {
            case .normal:
                switch trackingState {
                case .normal:
                    return
                default:
                    break
                }
                startScene()
                showEverything()
            case .notAvailable:
                switch trackingState {
                case .notAvailable:
                    return
                default:
                    break
                }
                hideEverything(reason: "Camera not available.".localized())
            case .limited(let reason):
                switch trackingState {
                case .limited(_):
                    return
                default:
                    break
                }
                let reasonString: String
                switch reason {
                case .excessiveMotion:
                    reasonString = "Excessive motion.".localized()
                case .insufficientFeatures:
                    reasonString = "Insufficient light conditions.".localized()
                case .initializing, .relocalizing:
                    reasonString = "Calibrating sensors.".localized()
                @unknown default:
                    reasonString = "Unknown.".localized()
                }
                hideEverything(reason: reasonString)
            }
        }
    }

    func hideEverything(reason: String) {
        print(reason)
    }

    func showEverything() {
        print("mostra tudo")
    }

    var sceneStarted: Bool = false
    func startScene() {
        if sceneStarted {
            return
        }
        if let frame = session.currentFrame {
            let camera = ARAnchor(name: AnchorNames.camera.rawValue, transform: frame.camera.transform)
            session.add(anchor: camera)
            sceneStarted = true
        }
    }

    var cancellables: [AnyCancellable] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let scene = SCNScene(named: "Scene.scn"),
            let batata = scene.rootNode.childNodes.first else {
            fatalError("Não havia uma cena")
        }
        potato = batata
        scnView.scene = scene

        _ = multipeerManager
        setupCoachingOverlay()
        configureSession()

        session.delegate = self
        scnView.delegate = self



        UIApplication.shared.isIdleTimerDisabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(gesture)
    }

    var isMoving: Bool = false
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
    }
}


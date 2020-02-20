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
import Combine

class ViewController: UIViewController {

    lazy var multipeerManager: MultipeerManager = MultipeerManager(serviceType: "potatoBomb", handler: self)
    public var player: Player?

    lazy var potato: ModelEntity? = try? ModelEntity.loadModel(named: "potato.usdz")

    @IBOutlet var arView: ARView!
    var scene: Scene {
        return arView.scene
    }
    var session: ARSession {
        return arView.session
    }

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

    var occlusionModel: ModelEntity = ModelEntity(mesh: .generatePlane(width: 2, height: 2), materials: [OcclusionMaterial()])

    func hideEverything(reason: String) {
        occlusionModel.position = [0,0,-0.1]
        potatoAnchor?.addChild(occlusionModel)
        print(reason)
    }

    func showEverything() {
        print("mostra tudo")
        occlusionModel.removeFromParent()
    }

    var potatoAnchor: AnchorEntity?
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
        arView.automaticallyConfigureSession = false

        _ = multipeerManager
        setupCoachingOverlay()
        configureSession()

        scene.subscribe(to: CollisionEvents.Began.self) { (collision) in
            print("\(collision.entityA) colidiu com \(collision.entityB)")
        }.store(in: &cancellables)

        session.delegate = self



        UIApplication.shared.isIdleTimerDisabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(gesture)
    }

    var isMoving: Bool = false
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let potato = potato else {
            fatalError("No potato tomato")
        }
        isMoving = !isMoving
        PotatoHelper.throwPotato(potato, potatoAnchor)
    }
}


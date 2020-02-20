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
    var aimingEntity: Entity = Entity()

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
        _ = potato
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
            self.collisionBegan(event: collision)
        }.store(in: &cancellables)

        session.delegate = self



        UIApplication.shared.isIdleTimerDisabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(gesture)
    }

    func collisionBegan(event: CollisionEvents.Began)  {
        if event.entityA.name == PotatoNames.potatoName.rawValue, let potato = event.entityA as? ModelEntity {
            collision(potato: potato, player: event.entityB)
        } else if event.entityB.name == PotatoNames.potatoName.rawValue, let potato = event.entityB as? ModelEntity {
            collision(potato: potato, player: event.entityA)
        }
        player?.hasPotato = false
    }

    func collision(potato: ModelEntity, player: Entity) {
        potato.removeFromParent()
        if let message = player.name.data(using: .utf8, allowLossyConversion: false) {
            PotatoHelper.setupPotato(potato)
            player.addChild(potato)
            potato.position = [0, 0, 0]
            multipeerManager.sendToAllPeers(message, reliably: true)
        }
    }

    var isMoving: Bool = false
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let potato = potato else {
            fatalError("No potato tomato")
        }
        guard player?.hasPotato == true else {
            return
        }
        if !isMoving {
            if let potatoSent = PotatoNames.potatoSent.rawValue.data(using: .utf8, allowLossyConversion: false) {
                multipeerManager.sendToAllPeers(potatoSent, reliably: true)
            }
            PotatoHelper.throwPotato(potato, relativeTo: aimingEntity)
        } else {
            if let potatoReset = PotatoNames.potatoReset.rawValue.data(using: .utf8, allowLossyConversion: false) {
                multipeerManager.sendToAllPeers(potatoReset, reliably: true)
            }
            PotatoHelper.resetPotato(potato)
        }
        isMoving = !isMoving
    }
}


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

class ViewController: UIViewController, ARSessionDelegate, MultipeerHandler {

    lazy var multipeerManager: MultipeerManager = MultipeerManager(serviceType: "potatoBomb", handler: self)

    public var player: Player?

    func peerDiscovered(_ id: MCPeerID) -> Bool {
        return true
    }

    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        return true
    }

    func peerJoined(_ id: MCPeerID) {

        guard let player = player else {
            fatalError("Não tinha um player")
        }

        if player.type == .host {

            session.getCurrentWorldMap { (map, error) in

                guard let map = map else {
                    fatalError("Não tinha um mapa")
                }

                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                    fatalError("Não conseguiu codificar o mapa")
                }

                self.multipeerManager.sendToAllPeers(data, reliably: true)
            }
        }
    }

    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        if !multipeerManager.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) else {
                    fatalError("Unexpectedly failed to encode collaboration data.")

            }
            let dataIsCritical = data.priority == .critical
            multipeerManager.sendToAllPeers(encodedData, reliably: dataIsCritical)
        }
    }

    func receivedData(_ data: Data, from peerID: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            session.update(with: collaborationData)
            return

        } else if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            player?.type == .join {

            let configuration = ARWorldTrackingConfiguration()
            configuration.isCollaborationEnabled = true
            configuration.environmentTexturing = .automatic
            configuration.initialWorldMap = worldMap
            session.run(configuration)
            session.delegate = self
        }
    }
    
    @IBOutlet var arView: ARView!
    var scene: Scene {
        return arView.scene
    }
    var session: ARSession {
        return arView.session
    }

    let coachingOverlay = ARCoachingOverlayView()
    
    override func viewDidLoad() {

        guard let player = player else {
            fatalError("Não tinha um player")
        }

        super.viewDidLoad()

        _ = multipeerManager
        setupCoachingOverlay()

        if player.type == .host {
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.isCollaborationEnabled = true
            configuration.environmentTexturing = .automatic
            session.run(configuration)
            session.delegate = self
        }

        UIApplication.shared.isIdleTimerDisabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(gesture)
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {

    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let participantAnchor = anchor as? ARParticipantAnchor {
                let anchorEntity = AnchorEntity(anchor: participantAnchor)

                let modelEntity = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [SimpleMaterial.init(color: .red, isMetallic: true)])
                anchorEntity.addChild(modelEntity)

                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
}


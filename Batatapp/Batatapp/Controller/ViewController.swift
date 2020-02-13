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

    func peerDiscovered(_ id: MCPeerID) -> Bool {
        return true
    }

    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        return true
    }

    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        if !multipeerManager.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                else { fatalError("Unexpectedly failed to encode collaboration data.") }
            let dataIsCritical = data.priority == .critical
            multipeerManager.sendToAllPeers(encodedData, reliably: dataIsCritical)
        }
    }

    func receivedData(_ data: Data, from peerID: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            session.update(with: collaborationData)
            return
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
        super.viewDidLoad()
        _ = multipeerManager
        setupCoachingOverlay()

        let configuration = ARWorldTrackingConfiguration()
        configuration.isCollaborationEnabled = true
        configuration.environmentTexturing = .automatic
        session.run(configuration)
        session.delegate = self

        UIApplication.shared.isIdleTimerDisabled = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(gesture)
    }

    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)

        if let firstResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
            let anchor = ARAnchor(name: AnchorNames.placement.rawValue, transform: firstResult.worldTransform)
            session.add(anchor: anchor)
        } else {
            print("Warning: Object placement failed.")
        }
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == AnchorNames.placement.rawValue {
                let boxLength: Float = 0.05
                let coloredCube = ModelEntity(mesh: MeshResource.generateBox(size: boxLength),
                                              materials: [SimpleMaterial(color: .white, isMetallic: true)])
                coloredCube.position = [0, boxLength / 2, 0]

                let anchorEntity = AnchorEntity(anchor: anchor)
                anchorEntity.addChild(coloredCube)
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
}

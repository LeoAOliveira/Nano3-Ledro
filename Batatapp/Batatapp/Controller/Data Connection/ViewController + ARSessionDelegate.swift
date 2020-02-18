//
//  ViewController + ARSessionDelegate.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 18/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import RealityKit
import ARKit

extension ViewController: ARSessionDelegate {

    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        if !multipeerManager.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) else {
                fatalError("Unexpectedly failed to encode collaboration data.")

            }
            let dataIsCritical = data.priority == .critical
            multipeerManager.sendToAllPeers(encodedData, reliably: dataIsCritical)
        }
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

    func configureSession() {
        guard let player = player else {
            fatalError("Não havia um player")
        }
        if player.type == PlayerType.host {
            let configuration = ARWorldTrackingConfiguration()
            configuration.isCollaborationEnabled = true
            configuration.environmentTexturing = .automatic
            session.run(configuration)
        } else {
            session.pause()
        }
    }
}

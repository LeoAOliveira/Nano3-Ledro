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
                let targetEntity = PlayerHelper.createTarget()
                targetEntity.name = participantAnchor.sessionIdentifier?.uuidString ?? ""
                anchorEntity.addChild(targetEntity)

                scene.addAnchor(anchorEntity)
            } else if anchor.name == AnchorNames.camera.rawValue,
                potatoAnchor == nil {
                let anchorEntity = AnchorEntity(anchor: anchor)
                self.potatoAnchor = anchorEntity
                aimingEntity.position = [0.25, 0, -1]
                anchorEntity.addChild(aimingEntity)

                if player?.type == PlayerType.host,
                    let potato = potato {
                    PotatoHelper.setupPotato(potato)
                    anchorEntity.addChild(potato)
                }
                scene.addAnchor(anchorEntity)
            }
        }
    }

    func configureSession() {
        guard let player = player else {
            fatalError("Não havia um player")
        }
        if player.type == PlayerType.host {
            self.player?.hasPotato = true
            let configuration = ARWorldTrackingConfiguration()
            configuration.isCollaborationEnabled = true
            configuration.environmentTexturing = .automatic
            session.run(configuration)
        } else {
            session.pause()
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        trackingState = frame.camera.trackingState
        if let potatoAnchor = potatoAnchor, !isMoving {
            let currentTransform = frame.camera.transform
            potatoAnchor.setTransformMatrix(currentTransform, relativeTo: nil)
        }
    }
}

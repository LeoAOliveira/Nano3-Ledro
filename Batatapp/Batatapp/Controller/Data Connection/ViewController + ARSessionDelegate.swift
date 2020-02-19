//
//  ViewController + ARSessionDelegate.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 18/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import RealityKit
import ARKit

extension ViewController: ARSessionDelegate, ARSCNViewDelegate {

    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        if !multipeerManager.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) else {
                fatalError("Unexpectedly failed to encode collaboration data.")

            }
            let dataIsCritical = data.priority == .critical
            multipeerManager.sendToAllPeers(encodedData, reliably: dataIsCritical)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARParticipantAnchor {
            let node = SCNNode(geometry: SCNSphere(radius: 2))
            node.addChildNode(node)
        } else if anchor.name == AnchorNames.camera.rawValue,
            let potato = potato,
            potato.parent == nil {
            potato.position = SCNVector3(0.25, 0, -0.5)
            potato.isHidden = false
            node.addChildNode(potato)
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

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        trackingState = frame.camera.trackingState
    }
}

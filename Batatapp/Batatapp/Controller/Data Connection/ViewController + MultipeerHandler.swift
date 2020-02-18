//
//  ViewController + MultipeerHandler.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 18/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import ARKit
import RealityKit
import MultipeerConnectivity

extension ViewController: MultipeerHandler {

    func peerDiscovered(_ id: MCPeerID) -> Bool {
        return true
    }

    func peerReceivedInvitation(_ id: MCPeerID) -> Bool {
        return true
    }

    func peerJoined(_ id: MCPeerID) {
        sendSession(to: id)
    }

    func receivedData(_ data: Data, from peerID: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            session.update(with: collaborationData)
            return
        } else if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
            runWorld(worldMap)
            return
        }
    }

    func runWorld(_ world: ARWorldMap) {
        guard let player = player else {
            fatalError("Não havia um player")
        }
        if player.type == PlayerType.join {
            let configuration = ARWorldTrackingConfiguration()
            configuration.isCollaborationEnabled = true
            configuration.environmentTexturing = .automatic
            configuration.initialWorldMap = world
            session.run(configuration)
        }
    }

    func sendSession(to id: MCPeerID) {
        guard let player = player else {
            fatalError("Não havia um player")
        }
        if player.type == PlayerType.host {
            session.getCurrentWorldMap { (map, error) in
                guard let map = map else {
                    fatalError("Não tinha um mapa")
                }
                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                    fatalError("Não foi possível codificar o mapa")
                }
                self.multipeerManager.sendToPeers(data, reliably: true, peers: [id])
            }
        }
    }
}

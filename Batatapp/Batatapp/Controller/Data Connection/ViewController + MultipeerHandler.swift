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
        DispatchQueue.main.async {
            if self.player?.type == PlayerType.host {
                Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 30...80), repeats: false) { (timer) in
                    if let endGame = "endGame".data(using: .utf8, allowLossyConversion: false) {
                        self.multipeerManager.sendToAllPeers(endGame, reliably: true)
                    }
                    self.endGame()
                }
            }
        }
    }

    func receivedData(_ data: Data, from peerID: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            session.update(with: collaborationData)
            return
        } else if let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
            runWorld(worldMap)
            return
        } else if let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as String? {
            if session.identifier.uuidString == message, let potato = potato {
                player?.hasPotato = true
                isMoving = false
                PotatoHelper.setupPotato(potato)
                potatoAnchor?.addChild(potato)
            } else if message == PotatoNames.potatoSent.rawValue,
                let potato = potato {
                let entity = Entity()
                potato.anchor?.addChild(entity)
                entity.position = [0, 0, 1]
                oldPosition = potato.position
                PotatoHelper.mockPotatoThrow(potato, relativeTo: entity)
                entity.removeFromParent()
            } else if message == PotatoNames.potatoReset.rawValue,
                let potato = potato {
                PotatoHelper.resetPotato(potato)
                potato.position = oldPosition
            } else if message == "endGame" {
                self.endGame()
            }
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
                    return
                }
                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                    return
                }
                self.multipeerManager.sendToPeers(data, reliably: true, peers: [id])
            }
        }
    }
}

//
//  Player.swift
//  Batatapp
//
//  Created by Leonardo Oliveira on 17/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import MultipeerConnectivity
import ARKit

struct Player {
    let id: MCPeerID
    let type: PlayerType?
}

enum PlayerType {
    case host
    case join
}

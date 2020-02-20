//
//  PlayerTarget.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 20/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import RealityKit

public class PlayerHelper {
    public static func createTarget() -> ModelEntity {
        let targetEntity = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [UnlitMaterial.init(color: .red)], collisionShape: .generateSphere(radius: 0.3), mass: 1)
        targetEntity.physicsBody?.mode = .static

        return targetEntity
    }
}

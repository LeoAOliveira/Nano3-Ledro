//
//  PotatoEntity.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 19/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import ARKit
import RealityKit

public class PotatoHelper {
    public static func setupPotato(_ potato: ModelEntity) {
        potato.name = PotatoNames.potatoName.rawValue
        potato.components.remove(PhysicsMotionComponent.self)
        potato.components.remove(CollisionComponent.self)
        potato.components.remove(PhysicsBodyComponent.self)
        potato.setScale([0.06, 0.06, 0.06], relativeTo: nil)
        potato.position = [0.25, 0, -0.5]
        potato.transform.rotation = simd_quatf(angle: .pi/2, axis: [0,0,1])
    }

    public static func throwPotato(_ potato: ModelEntity, relativeTo entity: Entity) {
        if potato.physicsBody == nil {
            let motion = PhysicsMotionComponent()
            let body = PhysicsBodyComponent(massProperties: .init(mass: 1), material: .default, mode: .dynamic)
            let collision = CollisionComponent(shapes: [.generateSphere(radius: 0.5)], mode: .trigger)
            potato.components.set([motion, collision, body])
        }
        potato.applyImpulse([-4000, 0, -3000], at: [0,0,0], relativeTo: entity)
    }

    public static func resetPotato(_ potato: ModelEntity) {
        potato.components.remove(PhysicsMotionComponent.self)
        potato.components.remove(PhysicsBodyComponent.self)
        potato.components.remove(CollisionComponent.self)
        potato.position = [0.25, 0, -0.5]
        potato.transform.rotation = simd_quatf(angle: .pi/2, axis: [0,0,1])
    }

    public static func mockPotatoThrow(_ potato: ModelEntity, relativeTo entity: Entity) {
        if potato.physicsBody == nil {
            DispatchQueue.main.sync {
                let motion = PhysicsMotionComponent()
                let body = PhysicsBodyComponent(massProperties: .init(mass: 1), material: .default, mode: .dynamic)
                let collision = CollisionComponent(shapes: [.generateSphere(radius: 0.5)], mode: .trigger, filter: .init(group: .init(rawValue: 0), mask: .init(rawValue: 0)))
                potato.components.set([motion, collision, body])

                potato.applyImpulse([0, 4000, 2500], at: [0,0,0], relativeTo: entity)
            }
        }
    }
}

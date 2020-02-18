//
//  MenuViewController.swift
//  Batatapp
//
//  Created by Leonardo Oliveira on 17/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MenuViewController: UIViewController {

    var player: Player?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func hostTap(_ sender: Any) {
        self.player = Player(id: MCPeerID(displayName: UIDevice.current.name), type: .host)
        performSegue(withIdentifier: "menuSegue", sender: self)
    }

    @IBAction func joinTap(_ sender: Any) {
        self.player = Player(id: MCPeerID(displayName: UIDevice.current.name), type: .join)
        performSegue(withIdentifier: "menuSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let controller = segue.destination as? ViewController {
            controller.player = self.player
        }
    }
}

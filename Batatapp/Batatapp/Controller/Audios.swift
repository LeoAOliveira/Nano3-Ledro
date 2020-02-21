//
//  Audios.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 20/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import AVFoundation

public class Audio {
    private static var player: AVAudioPlayer!
    public static func playBeep() {
        guard let url = Bundle.main.url(forResource: "Beep", withExtension: "m4a") else {
            fatalError("No beep boop")
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = Int.max
            player.play()

        } catch {
            fatalError("No audio")
        }
    }

    public static func playExplosion() {
        guard let url = Bundle.main.url(forResource: "Explosion", withExtension: "m4a") else {
            fatalError("No kabum")
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player.play()

        } catch {
            fatalError("No audio")
        }
    }
}

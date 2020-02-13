//
//  MultipeerManager.swift
//  Batatapp
//
//  Created by Pedro Giuliano Farina on 13/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import MultipeerConnectivity

public class MultipeerManager: NSObject {
    public let serviceType: String

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private lazy var session: MCSession = MCSession(peer: myPeerID)
    private lazy var advertiser: MCNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
    private lazy var browser: MCNearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)

    public var handler: MultipeerHandler

    public init(serviceType: String, handler: MultipeerHandler) {
        self.handler = handler
        self.serviceType = serviceType

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    public func sendToAllPeers(_ data: Data, reliably: Bool) {
        sendToPeers(data, reliably: reliably, peers: connectedPeers)
    }

    public func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
        guard !peers.isEmpty else { return }
        do {
            try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
        } catch {
            handler.failedSendingTo(peers: peers, err: error)
        }
    }

    public var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
}

extension MultipeerManager: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            handler.peerJoined(peerID)
        } else if state == .notConnected {
            handler.peerLeft(peerID)
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        handler.receivedData(data, from: peerID)
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        handler.receivedStream(stream, from: peerID)
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        handler.startedReceivingResource(resourceName, from: peerID)
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let url = localURL {
            handler.finishedReceivingResource(resourceName, from: peerID, answer: ResourceAnswer.success(at: url))
        } else if let error = error {
            handler.finishedReceivingResource(resourceName, from: peerID, answer: ResourceAnswer.fail(err: error))
        }
    }


}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if handler.peerDiscovered(peerID) {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        handler.peerLost(peerID)
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if handler.peerReceivedInvitation(peerID) {
            invitationHandler(true, self.session)
        }
    }
}


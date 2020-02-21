//
//  MenuViewController.swift
//  Batatapp
//
//  Created by Leonardo Oliveira on 17/02/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AVFoundation

class MenuViewController: UIViewController {

    var player: Player?

    var captureSession = AVCaptureSession()

    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice? {
        didSet{
            captureSession.stopRunning()
            setupInputOutput()
            captureSession.startRunning()
        }
    }
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?

    var image: UIImage?

    var isFrontFacing = false {
        didSet{
            if self.isFrontFacing {
                self.currentDevice = self.frontCamera
            } else {
                self.currentDevice = self.backCamera
            }
        }
    }

    var scale = CGFloat(1)
    var minScale = CGFloat(1)
    var maxScale = CGFloat(5)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaptureSession()
        setupDevice()
        setupPreviewLayer()
        captureSession.startRunning()

        setupPreviewLayer()
        // Do any additional setup after loading the view.
    }

    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentDevice = backCamera
    }

    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }

    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)

            // if there are inputs already, remove them
            if let input = captureSession.inputs.first {
                captureSession.removeInput(input)
            }
            captureSession.addInput(captureDeviceInput)

            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)

            // if there are outputs already, remove them
            if let output = captureSession.outputs.first {
                captureSession.removeOutput(output)
            }
            captureSession.addOutput(photoOutput!)

        } catch {
            print(error)
        }
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

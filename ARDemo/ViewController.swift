//
//  ViewController.swift
//  ARDemo
//
//  Created by Vivek Nagar on 6/20/17.
//  Copyright © 2017 Vivek Nagar. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    private var sceneView : ARSCNView = ARSCNView()
    private var sessionConfig: ARSessionConfiguration = ARWorldTrackingSessionConfiguration()
    var lastPosition:SCNVector3 = SCNVector3Zero
    var originalVector:SCNVector3 = SCNVector3Zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sceneView.frame = self.view.frame
        self.view.addSubview(sceneView)
        
        setupScene()
        setupUIControls()
        addPlayer()
        
        let tapRecognizer =  UITapGestureRecognizer(target: self, action: #selector(sceneTapped(_:)))
        sceneView.gestureRecognizers = [tapRecognizer]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed after a while.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the ARSession.
        restartPlaneDetection(on:true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func restartPlaneDetection(on:Bool) {
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingSessionConfiguration {
            if(on) {
                worldSessionConfig.planeDetection = .horizontal
            } else {
                worldSessionConfig.planeDetection = []
            }
            sceneView.session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
    }
    
    
    private func setupScene() {
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    var restartButton : UIButton?
    var messageLabel : UILabel?
    var addButton: UIButton?
    
    private func setupUIControls() {
        restartButton = UIButton(frame: CGRect.zero)
        guard let restartButton = restartButton else {
            print("Could not create restart button")
            return
        }
        restartButton.setBackgroundImage(UIImage(named: "restart"), for: UIControlState.normal)
        restartButton.setBackgroundImage(UIImage(named: "restartPressed"), for: UIControlState.highlighted)
        restartButton.addTarget(self, action: #selector(restartAction(_:)), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(restartButton)
        
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        // Create a top space constraint
        var constraint = NSLayoutConstraint (item: restartButton,
                                             attribute: NSLayoutAttribute.top,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: sceneView,
                                             attribute: NSLayoutAttribute.top,
                                             multiplier: 1,
                                             constant: 20)
        sceneView.addConstraint(constraint)
        
        // Create a right space constraint
        constraint = NSLayoutConstraint (item: restartButton,
                                         attribute: NSLayoutAttribute.right,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: sceneView,
                                         attribute: NSLayoutAttribute.right,
                                         multiplier: 1,
                                         constant: -20)
        sceneView.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: restartButton,
                                        attribute: .width,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 20)
        sceneView.addConstraint(constraint)
        
        messageLabel = UILabel(frame: CGRect.zero)
        guard let messageLabel = messageLabel else {
            print("Could not create message label")
            return
        }
        messageLabel.backgroundColor = .gray
        messageLabel.alpha = 0.5
        messageLabel.text = "Test string"
        sceneView.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        // Create a top space constraint
        constraint = NSLayoutConstraint (item: messageLabel,
                                         attribute: NSLayoutAttribute.top,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: sceneView,
                                         attribute: NSLayoutAttribute.top,
                                         multiplier: 1,
                                         constant: 20)
        sceneView.addConstraint(constraint)
        
        // Create a left space constraint
        constraint = NSLayoutConstraint (item: messageLabel,
                                         attribute: NSLayoutAttribute.left,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: sceneView,
                                         attribute: NSLayoutAttribute.left,
                                         multiplier: 1,
                                         constant: 20)
        sceneView.addConstraint(constraint)
        // Create a right space constraint
        constraint = NSLayoutConstraint (item: messageLabel,
                                         attribute: NSLayoutAttribute.right,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: restartButton,
                                         attribute: NSLayoutAttribute.left,
                                         multiplier: 1,
                                         constant: -10)
        sceneView.addConstraint(constraint)
        
        addButton = UIButton(frame: CGRect.zero)
        guard let addButton = addButton else {
            print("Could not create add button")
            return
        }
        addButton.setBackgroundImage(UIImage(named: "add"), for: UIControlState.normal)
        addButton.setBackgroundImage(UIImage(named: "addPressed"), for: UIControlState.highlighted)
        addButton.addTarget(self, action: #selector(addAction(_:)), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        // Create a bottom space constraint
        constraint = NSLayoutConstraint (item: addButton,
                                         attribute: NSLayoutAttribute.bottom,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: sceneView,
                                         attribute: NSLayoutAttribute.bottom,
                                         multiplier: 1,
                                         constant: -20)
        sceneView.addConstraint(constraint)
        
        // Create a right space constraint
        constraint = NSLayoutConstraint (item: addButton,
                                         attribute: NSLayoutAttribute.centerX,
                                         relatedBy: NSLayoutRelation.equal,
                                         toItem: sceneView,
                                         attribute: NSLayoutAttribute.centerX,
                                         multiplier: 1,
                                         constant: 0)
        sceneView.addConstraint(constraint)
    }
    
    private func restartExperience() {
        guard let messageLabel = messageLabel else {
            return
        }
        DispatchQueue.main.async {
            messageLabel.text = "STARTING A NEW SESSION"
            self.restartPlaneDetection(on:true)
        }
    }
    
    @objc func sceneTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        guard let player = player else {
            return
        }
        guard let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(location, player.position) else {
            return
        }
        print("point on infinite plane is \(String(describing: pointOnInfinitePlane))")
        
        let angle = getAngleFromDirection(currentPosition: player.position, target: pointOnInfinitePlane)
        player.eulerAngles.y = angle
        player.changeAnimationState(newState: .Walk)
        
        let moveAction = SCNAction.move(to: pointOnInfinitePlane, duration: 2.0)
        let action = SCNAction.run { node -> Void in
            player.changeAnimationState(newState: .Idle)
        }
        player.runAction(SCNAction.sequence([moveAction, action]))
    }
    
    private func getAngleFromDirection(currentPosition:SCNVector3, target:SCNVector3) -> Float
    {
        let delX = target.x - currentPosition.x;
        let delZ = target.z - currentPosition.z;
        let angleInRadians =  atan2(delX, delZ);
        
        return Float(angleInRadians)
    }
    
    @objc func restartAction(_ sender:UIButton) {
        updateVirtualObjectTransform()
    }
    
    @objc func addAction(_ sender:UIButton) {
        guard let messageLabel = messageLabel else {
            return
        }
        messageLabel.text = "Add object to AR session"
        guard let player = player else {
            print("Cannot find player")
            return
        }
        //Turn off plane detection
        self.restartPlaneDetection(on: false)
        player.position = lastPosition
        sceneView.scene.rootNode.addChildNode(player)
        displayVirtualObjectTransform()
    }
    
    var planes = [ARPlaneAnchor: SCNNode]()
    let grid = UIImage(named: "Models.scnassets/plane_grid.png")
    
    private func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let pos = SCNVector3.positionFromTransform(anchor.transform)
        print("New Surface DETECTED AT \(pos.friendlyString())")
        
        let planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        planeGeometry.materials = [SCNMaterial.material(withDiffuse: grid)]
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        planeNode.position = SCNVector3(pos.x, pos.y-0.002, pos.z) // 2 mm below the origin of plane.
        print("Plane node AT \(planeNode.position.friendlyString())")
        
        
        planes[anchor] = planeNode
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        guard let messageLabel = messageLabel else {
            return
        }
        messageLabel.text = "SURFACE DETECTED"
        lastPosition = pos
    }
    
    private func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            //print("Updating existing plane")
            let pos = SCNVector3.positionFromTransform(anchor.transform)
            let geometry = plane.geometry as! SCNPlane
            geometry.width = CGFloat(anchor.extent.x)
            geometry.height = CGFloat(anchor.extent.z)
            
            plane.position = pos
        }
    }
    
    private func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            print("Removing old plane")
            plane.removeFromParentNode()
        }
    }
    
    var player:PlayerCharacter?
    
    private func addPlayer() {
        let skinnedModelName = "Models.scnassets/explorer/explorer_skinned.dae"
        guard let modelScene = SCNScene(named:skinnedModelName) else {
            print("Cannot load model scene:\(skinnedModelName)")
            return
        }
        let rootNode = modelScene.rootNode
        
        rootNode.enumerateChildNodes({
            child, stop in
            // do something with node or stop
            if(child.name == "group") {
                self.player = PlayerCharacter(characterNode:child, id:"Player")
                self.player?.scale = SCNVector3Make(0.005, 0.005, 0.005)
            }
        })
        
    }
    
    private func displayVirtualObjectTransform() {
        guard let object = player, let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            return
        }
        
        print("Camera euler angles: \(String(describing: sceneView.session.currentFrame?.camera.eulerAngles))")
        let cameraPos = SCNVector3.positionFromTransform(cameraTransform)
        let vectorToCamera = cameraPos - object.position
        originalVector = vectorToCamera
        let distanceToUser = vectorToCamera.length()
        
        var angleDegrees = Int(((object.eulerAngles.y) * 180) / Float.pi) % 360
        if angleDegrees < 0 {
            angleDegrees += 360
        }
        
        let distance = String(format: "%.2f", distanceToUser)
        let scale = String(format: "%.2f", object.scale.x)
        print("Distance: \(distance) m\nRotation: \(angleDegrees)°\nScale: \(scale)x")
        guard let messageLabel = messageLabel else {
            return
        }
        messageLabel.text = "Distance: \(distance) m\nRotation: \(angleDegrees)°\nScale: \(scale)x"
        
        var angleToCameraInDegrees = 90 - vectorToCamera.angleToCameraInDegrees()
        if(angleToCameraInDegrees < 0) {
            angleToCameraInDegrees += 360
        }
        print("Angle to camera in degrees:\(angleToCameraInDegrees)")
    }
    
    private func updateVirtualObjectTransform() {
        guard let object = player, let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            return
        }
        
        let cameraPos = SCNVector3.positionFromTransform(cameraTransform)
        let vectorToCamera = cameraPos - object.position
        
        let angle = vectorToCamera.angleBetween(originalVector)
        
        var angleDegrees = Int(((angle) * 180) / Float.pi) % 360
        if angleDegrees < 0 {
            angleDegrees += 360
        }
        
        //print("ANGLE IN DEGREES BETWEEN VECTORS is \(angleDegrees)")
        object.eulerAngles.y = angle
        
    }
}

extension ViewController : ARSCNViewDelegate {
    //MARK: - ARSCNViewDelegate methods
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // updateVirtualObjectTransform()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.addPlane(node: node, anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.removePlane(anchor: planeAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        guard let arError = error as? ARError else { return }
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        guard let messageLabel = messageLabel else {
            return
        }
        messageLabel.text = sessionErrorMsg
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        restartExperience()
        guard let messageLabel = messageLabel else {
            return
        }
        messageLabel.text = "RESETTING SESSION"
    }
}

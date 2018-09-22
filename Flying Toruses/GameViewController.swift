//
//  GameViewController.swift
//  Flying Toruses
//
//  Created by Denis Bystruev on 22/09/2018.
//  Copyright © 2018 Denis Bystruev. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add lights to the scene
        createLights(positions: [/*SCNVector3(0, 10, 10)*/]).forEach { node in scene.rootNode.addChildNode(node)
        }
        
        // add a plane to the scene
        scene.rootNode.addChildNode(createPlane(0, -2, 0))

        // add a torus to the scene
        let ring = createRing(0, 0, -100)
        scene.rootNode.addChildNode(ring)
        
        // create a camera
        let camera = createCamera(0, 5, 5)
        
        // make camera to look at torus all the time
        let constraint = SCNLookAtConstraint(target: ring)
        constraint.isGimbalLockEnabled = true
        camera.constraints = [constraint]
        
        // add the camera to the scene
        scene.rootNode.addChildNode(camera)
        
        
        // animate the 3d object
        let interval = TimeInterval(Int.max)
        
        ring.runAction(
            SCNAction.customAction(duration: interval) {
                node, elapsedTime in
                node.position = self.getPosition(at: TimeInterval(elapsedTime))
            }
        )
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func createCamera(_ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        // create a camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // place the camera
        cameraNode.position = SCNVector3(x: x, y: y, z: z)
        
        return cameraNode
    }
    
    func createLights(positions: [SCNVector3]) -> [SCNNode] {
        var lightNodes = [SCNNode]()
        
        // create and add lights to the scene
        positions.forEach { position in
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = position
            lightNodes.append(lightNode)
        }
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        lightNodes.append(ambientLightNode)
        
        return lightNodes
    }
    
    func createRing(_ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let gold = SCNMaterial()
        gold.diffuse.contents = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        let torus = SCNTorus(ringRadius: 1, pipeRadius: 0.25)
        torus.materials = [gold]
        
        let torusNode = SCNNode(geometry: torus)
//        torusNode.eulerAngles.x += Float.pi / 2
        torusNode.position = SCNVector3(x, y, z)
        
        let light = SCNLight()
        light.type = .omni
        torusNode.light = light
        
        return torusNode
    }
    
    func createPlane(_ x: Float, _ y: Float, _ z: Float) -> SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "Earth Texture")
        
        let plane = SCNPlane(width: 250, height: 250)
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x -= Float.pi / 2
        planeNode.position = SCNVector3(x, y, z)
        
        return planeNode
    }
    
    func getPosition(at time: TimeInterval) -> SCNVector3 {
        let radius = Float(50)
        let x = radius * Float(cos(time / 2))
        let z = radius * Float(sin(time))
        
//        print(#function, x, z)
        
        return SCNVector3(x, 0, z)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}

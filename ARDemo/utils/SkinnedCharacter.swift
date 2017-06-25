//
//  SkinnedCharacter.swift
//  ARDemo
//
//  Created by Vivek Nagar on 6/24/17.
//  Copyright © 2017 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit
import QuartzCore

class SkinnedCharacter : SCNNode, CAAnimationDelegate {
    var mainSkeleton:SCNNode!
    var animationsDict = Dictionary<String, CAAnimation>()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(rootNode:SCNNode) {
        super.init()
        
        //print("Root node name in scene:\(rootNode.name)")
        rootNode.enumerateChildNodes({
            child, stop in
            // do something with node or stop
            print("Child node name:\(String(describing: child.name))")
            if let skinner = child.skinner {
                self.mainSkeleton = skinner.skeleton
                //print("Main skeleton name: \(self.mainSkeleton.name)")
                stop.pointee = true
                self.addChildNode(skinner.skeleton!)
            }
        })
        
        rootNode.enumerateChildNodes({
            child, stop in
            // do something with node or stop
            if let _ = child.geometry {
                //print("Child node with geometry name:\(child.name)")
                self.addChildNode(child)
            }
        })
        
    }
    
    func cachedAnimationForKey(key:String) -> CAAnimation? {
        return animationsDict[key]
    }
    
    class func loadAnimationNamed(animationName:String, fromSceneNamed sceneName:String, withSkeletonNode skeletonNode:String) -> CAAnimation?
    {
        var animation:CAAnimation?
        
        //Load the animation
        guard let scene = SCNScene(named: sceneName) else {
            return nil
        }
        
        //Grab the node and its animation
        if let node = scene.rootNode.childNode(withName: skeletonNode, recursively: true) {
            animation = node.animation(forKey:animationName)
            if(animation == nil) {
                print("No animation for key \(animationName)", terminator: "")
                return nil
            }
        } else {
            return nil
        }
        
        // Blend animations for smoother transitions
        animation?.fadeInDuration = 0.3
        animation?.fadeOutDuration = 0.3
        
        return animation;
        
    }
    
    func loadAndCacheAnimation(daeFile:String, withSkeletonNode skeletonNode:String, withName name:String, forKey key:String) -> CAAnimation?
    {
        
        if let anim = type(of: self).loadAnimationNamed(animationName: name, fromSceneNamed:daeFile, withSkeletonNode:skeletonNode) {
            self.animationsDict[key] = anim
            anim.delegate = self;
            return anim
        } else {
            return nil
        }
    }
    
    func loadAndCacheAnimation(daeFile:String, withSkeletonNode skeletonNode:String, forKey key:String) -> CAAnimation?
    {
        return loadAndCacheAnimation(daeFile: daeFile, withSkeletonNode:skeletonNode, withName:key, forKey:key)
    }
    
}

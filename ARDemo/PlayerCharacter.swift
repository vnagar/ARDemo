//
//  PlayerCharacter.swift
//  ARDemo
//
//  Created by Vivek Nagar on 6/24/17.
//  Copyright © 2017 Vivek Nagar. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

enum PlayerAnimationState : Int {
    case Die = 0,
    Run,
    Jump,
    JumpFalling,
    JumpLand,
    Idle,
    GetHit,
    Bored,
    RunStart,
    RunStop,
    Walk,
    Unknown
}

enum PlayerStatus : Int {
    case Inactive = 0,
    Alive,
    Dead
}

class PlayerCharacter : SkinnedCharacter {
    var status = PlayerStatus.Inactive
    
    let speed:Float = 0.1
    let assetDirectory = "Models.scnassets/explorer/"
    let skeletonName = "Bip001_Pelvis"
    var currentState : PlayerAnimationState = PlayerAnimationState.Idle
    var previousState : PlayerAnimationState = PlayerAnimationState.Idle
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(characterNode:SCNNode, id:String) {
        super.init(rootNode: characterNode)
        
        self.name = id
        self.status = PlayerStatus.Alive
        
        // Load the animations and store via a lookup table.
        self.setupIdleAnimation()
        self.setupWalkAnimation()
        self.setupBoredAnimation()
        self.setupHitAnimation()
        
        self.changeAnimationState(newState: PlayerAnimationState.Idle)
    }
    
    
    class func keyForAnimationType(animType:PlayerAnimationState) -> String!
    {
        switch (animType) {
        case .Bored:
            return "bored-1"
        case .Die:
            return "die-1"
        case .GetHit:
            return "hit-1"
        case .Idle:
            return "idle-1"
        case .Jump:
            return "jump_start-1"
        case .JumpFalling:
            return "jump_falling-1"
        case .JumpLand:
            return "jump_land-1"
        case .Run:
            return "run-1"
        case .RunStart:
            return "run_start-1"
        case .RunStop:
            return "run_stop-1"
        case .Walk:
            return "walk-1"
        default:
            return "unknown"
        }
    }
    
    func changeAnimationState(newState:PlayerAnimationState)
    {
        guard let newKey = PlayerCharacter.keyForAnimationType(animType: newState), let currentKey = PlayerCharacter.keyForAnimationType(animType: previousState) else {
            return
        }
        
        guard let runAnim = self.cachedAnimationForKey(key: newKey) else {
            return
        }
        runAnim.fadeInDuration = 0.15;
        self.mainSkeleton.removeAnimation(forKey:currentKey, fadeOutDuration:0.15)
        self.mainSkeleton.addAnimation(runAnim, forKey:newKey)
    }
    
    func setupIdleAnimation() {
        let fileName = assetDirectory + "idle.dae"
        guard let idleAnimation = self.loadAndCacheAnimation(daeFile: fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(animType: .Idle)) else {
            return
        }
        idleAnimation.repeatCount = Float.greatestFiniteMagnitude;
        idleAnimation.fadeInDuration = 0.15;
        idleAnimation.fadeOutDuration = 0.15;
    }
    
    func setupWalkAnimation() {
        let fileName = assetDirectory + "walk.dae"
        
        guard let walkAnimation = self.loadAndCacheAnimation(daeFile: fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(animType: .Walk)) else {
            return
        }
        walkAnimation.repeatCount = Float.greatestFiniteMagnitude;
        walkAnimation.fadeInDuration = 0.15;
        walkAnimation.fadeOutDuration = 0.15;
    }
    
    func setupBoredAnimation() {
        let fileName = assetDirectory + "bored.dae"
        
        guard let boredAnimation = self.loadAndCacheAnimation(daeFile: fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(animType: .Bored)) else {
            return
        }
        boredAnimation.repeatCount = Float.greatestFiniteMagnitude;
        boredAnimation.fadeInDuration = 0.15;
        boredAnimation.fadeOutDuration = 0.15;
    }
    
    func setupHitAnimation() {
        let fileName = assetDirectory + "hit.dae"
        
        guard let animation = self.loadAndCacheAnimation(daeFile: fileName, withSkeletonNode:skeletonName, forKey:PlayerCharacter.keyForAnimationType(animType: .GetHit)) else {
            return
        }
        animation.fadeInDuration = 0.15;
        animation.fadeOutDuration = 0.15;
        animation.repeatCount = Float.greatestFiniteMagnitude;
    }
    
    func updatePosition(velocity:CGPoint) {
        let delX = velocity.x * CGFloat(speed)
        let delZ = velocity.y * CGFloat(speed)
        
        #if os(iOS)
            var newPlayerPos = SCNVector3Make(self.position.x+Float(delX), self.position.y, self.position.z+Float(delZ))
        #else
            var newPlayerPos = SCNVector3Make(self.position.x+CGFloat(delX), self.position.y, self.position.z+CGFloat(delZ))
        #endif
        //let angleDirection = GameUtilities.getAngleFromDirection(self.position, target:newPlayerPos)
        let angleDirection = 0.0
        let height:Float = 0.0
        
        newPlayerPos = SCNVector3Make(self.position.x+Float(delX), height, self.position.z+Float(delZ))
        self.rotation = SCNVector4Make(0, 1, 0, Float(angleDirection))
        
        self.position = newPlayerPos
    }
    
    
}

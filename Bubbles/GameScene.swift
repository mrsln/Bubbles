//
//  GameScene.swift
//  Bubbles
//
//  Created by Надежда Елисеева on 22.02.16.
//  Copyright (c) 2016 Marsel LLC. All rights reserved.
//

import SpriteKit

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}

class GameScene: SKScene {
    var label = SKLabelNode(fontNamed: "Chalkduster")
    var maxSpeedLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score = 0
    var lastPoof = NSDate()
    var lastPoofs = [Double]()
    var minSpeed = 1.0
    var maxSpeed = 8.0

    override func didMoveToView(view: SKView) {
        label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "0"
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: 40, y: size.height - 40)
        addChild(label)
        
        maxSpeedLabel = SKLabelNode(fontNamed: "Chalkduster")
        maxSpeedLabel.text = NSString(format:"%.2f", maxSpeed) as String
        maxSpeedLabel.fontSize = 40
        maxSpeedLabel.fontColor = SKColor.blackColor()
        maxSpeedLabel.position = CGPoint(x: 160, y: size.height - 40)
        //addChild(maxSpeedLabel)

        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                    SKAction.runBlock(addBalloon),
                    SKAction.waitForDuration(0.5)
                ])
            ))
        if #available(iOS 9.0, *) {
            let backgroundMusic = SKAudioNode(fileNamed: "feelin-good.mp3")
            backgroundMusic.autoplayLooped = true
            addChild(backgroundMusic)
        } else {
            // Fallback on earlier versions
        }

    }
    
    func addBalloon() {
        let baloons = ["blue", "orange", "gold", "yellow", "red", "green", "pink", "white"]
        let imgI = Int(arc4random_uniform(8))
        let img = baloons[imgI]
        let balloon = SKSpriteNode(imageNamed: img)
        let actualX = random(min: balloon.size.width, max: size.width - balloon.size.width*2)
        balloon.position = CGPoint(x: actualX, y: 0)
        balloon.userInteractionEnabled = false
        balloon.name = "balloon"
        addChild(balloon)
        
        let actualDuration = random(min: CGFloat(minSpeed), max: CGFloat(maxSpeed))
        
        // Create the actions
        let actionMove = SKAction.moveToY(size.width, duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        balloon.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let positionInScene = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        
        if let name = touchedNode.name {
            if name == "balloon" {
                let sounds = ["1-pop.wav", "2-pop.wav", "3-pop.wav", "4-pop.wav", "5-pop.wav", "6-pop.wav"]
                let soundI = Int(arc4random_uniform(4))
                let soundF = sounds[soundI]
                runAction(SKAction.playSoundFileNamed(soundF, waitForCompletion: false))

                touchedNode.removeFromParent()
                score = score + 1
                label.text = String(score)
                
                let reactionTime = NSDate().timeIntervalSinceDate(lastPoof)
                lastPoof = NSDate()
                lastPoofs.insert(reactionTime, atIndex: 0)
                lastPoofs = Array(lastPoofs.reverse().suffix(10))
                
                let avg = lastPoofs.reduce(0) { $0 + $1 } / Double(lastPoofs.count)
                if (avg > maxSpeed) {
                    maxSpeed += 0.5
                } else if (maxSpeed > 2) {
                    maxSpeed -= 0.5
                }
            }
        } else {
            maxSpeed += 0.5
        }
        maxSpeedLabel.text = NSString(format:"%.2f", maxSpeed) as String

    }
   
    override func update(currentTime: CFTimeInterval) {
    }
}

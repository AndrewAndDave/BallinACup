//
//  GameScene.swift
//  LineRiderGame
//
//  Created by Andrew Solesa on 2017-04-17.
//  Copyright © 2017 KSG. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene, UIScrollViewDelegate
{
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var mutablePath: CGMutablePath!
    var splineShapeNode: SKShapeNode!
    
    var cleanLevel = false
    
    var ball: SKShapeNode?
    
    var ballFlag: Bool = false
    var level: Int = 0
    var score: Int = 0
    
    var scrollView: UIScrollView?
    
    var hideScrollViewButton: UIButton?
    var hideScrollViewButtonOriginalX: CGFloat?
    var hideScrollViewButtonOriginalY: CGFloat?
    
    var spawnImage: SKShapeNode?
    
    var basketImage: SKShapeNode?
    var backBoard: SKShapeNode?
    var insideBasket: SKShapeNode?
    var outsideBasket: SKShapeNode?
    var slantedBasketWall: SKShapeNode?
    
    var arrayOfNodes = [SKShapeNode]()
    var nodeOriginalXArray = [CGFloat]()
    var nodeOriginalYArray = [CGFloat]()
    
    var arrayOfLines = [SKShapeNode]()
    var linesOriginalXArray = [CGFloat]()
    var linesOriginalYArray = [CGFloat]()
    
    var arrayOfStars = [SKShapeNode]()
    var starsOriginalXArray = [CGFloat]()
    var starsOriginalYArray = [CGFloat]()
    
    var arrayOfStarsHit = [Bool]()
    var starsToRemove = Set<SKShapeNode>()
    
    override func didMove(to view: SKView)
    {
        /* Setup your scene here */
        self.createLevel(levelNumber: level)
    }
    
    override func willMove(from view: SKView)
    {
        scrollView = nil
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        adjustContent(scrollView: scrollView)
    }
    
    func adjustContent(scrollView: UIScrollView)
    {
        hideScrollViewButton!.center.x = hideScrollViewButtonOriginalX! + scrollView.contentOffset.x
        hideScrollViewButton!.center.y = hideScrollViewButtonOriginalY! + scrollView.contentOffset.y
        
        var i = 0
        for Node in arrayOfNodes
        {
            Node.position.x = nodeOriginalXArray[i] - scrollView.contentOffset.x
            Node.position.y = nodeOriginalYArray[i] + scrollView.contentOffset.y
            
            i += 1
        }
        
        i = 0
        for Line in arrayOfLines
        {
            Line.position.x = linesOriginalXArray[i] - scrollView.contentOffset.x
            Line.position.y = linesOriginalYArray[i] + scrollView.contentOffset.y
            
            i += 1
        }
        
        i = 0
        for Star in arrayOfStars
        {
            Star.position.x = starsOriginalXArray[i] - scrollView.contentOffset.x
            Star.position.y = starsOriginalYArray[i] + scrollView.contentOffset.y
            
            i += 1
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if cleanLevel
        {
            cleanUpLevel()
            
            cleanLevel = false
        }
        
        for star in starsToRemove
        {
            star.removeFromParent()
        }
        
        starsToRemove.removeAll()
        
        self.checkBasketBoundary()
        self.checkStarBoundary()
    }
    
    func checkBasketBoundary()
    {
        if ball != nil
        {
            if ball!.intersects(insideBasket!)
            {
                let ballTransparencyAnimation = SKAction.fadeOut(withDuration: 3)
                
                ball?.run(ballTransparencyAnimation, completion: {
                    self.cleanLevel = true
                    
                    self.level += 1
                })
            }
        }
    }
    
    func checkStarBoundary()
    {
        if ball != nil
        {
            for count in 0..<arrayOfStars.count
            {
                if ball!.intersects(arrayOfStars[count]) && !arrayOfStarsHit[count]
                {
                    arrayOfStarsHit[count] = true
                    
                    let starMoveUpAnimation = SKAction.move(to: CGPoint(x: starsOriginalXArray[count], y: starsOriginalYArray[count] + 10), duration: 1)
                    let starMoveDownAnimation = SKAction.move(to: CGPoint(x: starsOriginalXArray[count], y: starsOriginalYArray[count]), duration: 1)
                    let starTransparencyAnimation = SKAction.fadeOut(withDuration: 3)
                    
                    arrayOfStars[count].run(SKAction.sequence([starMoveUpAnimation, starMoveDownAnimation, starTransparencyAnimation]), completion:
                        {
                            self.starsToRemove.update(with: self.arrayOfStars[count])
                            
                            self.score += 10
                        })
                }
            }
        }
    }
    
    func createLevel(levelNumber level: Int)
    {
        switch(level)
        {
        case 0:
            if self.scrollView?.isHidden != true
            {
                self.scrollView = setUpScrollView(withContentSize: 1000, andHeight: 1000)
            }
            self.createSpawnMarker(withX: -292, withY: 120)
            self.createBasket(withImage: "basket", withX: 100, withY: 0)
            
        case 1:
            if self.scrollView?.isHidden != true
            {
                self.scrollView = setUpScrollView(withContentSize: 1000, andHeight: 1000)
            }
            self.createSpawnMarker(withX: -292, withY: 100)
            self.createBasket(withImage: "basket", withX: 200, withY: -100)
            self.createStarsMarker(withStars: [(x: -263, y:34), (x: -318, y:-33), (x: -138, y:-84)])
            break
            
        default:
            break
        }
        setOriginalPositionsForStaticNodes()
    }
    
    func setUpScrollView(withContentSize Width: CGFloat, andHeight: CGFloat) -> UIScrollView
    {
        let scrollView = UIScrollView(frame: self.view!.frame)
        scrollView.contentSize.width = Width
        scrollView.contentSize.height = andHeight
        scrollView.delegate = self
        self.view?.addSubview(scrollView)
        return scrollView
    }
    
    func createSpawnMarker(withX x: CGFloat, withY y: CGFloat)
    {
        let textureSpawn: SKTexture! = SKTexture(imageNamed: "spawn")
        let spawnSize: CGSize = textureSpawn.size()
        
        spawnImage = SKShapeNode(rectOf: spawnSize)
        spawnImage!.fillTexture = textureSpawn
        spawnImage!.fillColor = SKColor.white
        spawnImage!.position = CGPoint(x: x, y: y)
        self.addChild(spawnImage!)
        
        arrayOfNodes.append(spawnImage!)
    }
    
    func createStarsMarker(withStars stars: [(x: CGFloat, y: CGFloat)])
    {
        for star in stars
        {
            let textureStar: SKTexture! = SKTexture(imageNamed: "Star")
            let starSize: CGSize = textureStar.size()
            
            let starImage = SKShapeNode(rectOf: starSize)
            starImage.fillTexture = textureStar
            starImage.fillColor = SKColor.white
            starImage.lineWidth = 0.0
            starImage.position = CGPoint(x: star.x, y: star.y)
            self.addChild(starImage)
            
            starsOriginalXArray.append(star.x)
            starsOriginalYArray.append(star.y)
            
            arrayOfStars.append(starImage)
            arrayOfStarsHit.append(false)
        }
    }
    
    func createBasket(withImage image: String, withX x: CGFloat, withY y: CGFloat)
    {
        createBasketImage(withImage: image, withX: x, withY: y)
        
        createBasketBackBoard(withX: x, withY: y)
        
        createBasketHoop(withX: x, withY: y)
    }
    
    func createBasketImage(withImage image: String, withX x: CGFloat, withY y: CGFloat)
    {
        let textureBasket : SKTexture! = SKTexture(imageNamed: image)
        let basketSize: CGSize = textureBasket.size()
        
        basketImage = SKShapeNode(rectOf: basketSize)
        basketImage!.fillTexture = textureBasket
        basketImage!.fillColor = SKColor.white
        basketImage!.lineWidth = 0.0
        basketImage!.position = CGPoint(x: x, y: y)
        self.addChild(basketImage!)
        
        arrayOfNodes.append(basketImage!)
    }
    
    func createBasketBackBoard(withX x: CGFloat, withY y: CGFloat)
    {
        backBoard = SKShapeNode(rectOf: CGSize(width: 8, height: 80))
        backBoard!.strokeColor = UIColor.clear
        backBoard!.position = CGPoint(x: x + 23, y: y)
        backBoard!.physicsBody = SKPhysicsBody(edgeChainFrom: backBoard!.path!)
        self.addChild(backBoard!)
        
        arrayOfNodes.append(backBoard!)
    }
    
    func createBasketHoop(withX x: CGFloat, withY y: CGFloat)
    {
        let insideBasketBezierPath = UIBezierPath()
        insideBasketBezierPath.move(to: CGPoint(x: -4.0, y: 10.0))
        insideBasketBezierPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        insideBasketBezierPath.addLine(to: CGPoint(x: 31.0, y: 0.0))
        insideBasketBezierPath.addLine(to: CGPoint(x: 32.0, y: 10.0))
        
        insideBasket = SKShapeNode(path: insideBasketBezierPath.cgPath)
        insideBasket!.strokeColor = UIColor.clear
        insideBasket!.position = CGPoint(x: x - 22, y: y - 41)
        insideBasket!.physicsBody = SKPhysicsBody(edgeChainFrom: insideBasket!.path!)
        self.addChild(insideBasket!)
        
        arrayOfNodes.append(insideBasket!)
        
        let outsideBasketBezierPath = UIBezierPath()
        outsideBasketBezierPath.move(to: CGPoint(x: -5.0, y: 18.0))
        outsideBasketBezierPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        outsideBasketBezierPath.addLine(to: CGPoint(x: 33.0, y: 0.0))
        outsideBasketBezierPath.addLine(to: CGPoint(x: 35.0, y: 18.0))
        
        outsideBasket = SKShapeNode(path: outsideBasketBezierPath.cgPath)
        outsideBasket!.strokeColor = UIColor.clear
        outsideBasket!.position = CGPoint(x: x - 23, y: y - 43)
        outsideBasket!.physicsBody = SKPhysicsBody(edgeChainFrom: outsideBasket!.path!)
        self.addChild(outsideBasket!)
        
        arrayOfNodes.append(outsideBasket!)
        
        let slantedBasketWallBezierPath = UIBezierPath()
        slantedBasketWallBezierPath.move(to: CGPoint(x: 5.0, y: 11.0))
        slantedBasketWallBezierPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        
        slantedBasketWall = SKShapeNode(path: slantedBasketWallBezierPath.cgPath)
        slantedBasketWall!.strokeColor = UIColor.clear
        slantedBasketWall!.position = CGPoint(x: x + 13, y: y - 25)
        slantedBasketWall!.physicsBody = SKPhysicsBody(edgeChainFrom: slantedBasketWall!.path!)
        self.addChild(slantedBasketWall!)
        
        arrayOfNodes.append(slantedBasketWall!)
        
    }
    
    func setOriginalPositionsForStaticNodes()
    {
        for node in arrayOfNodes
        {
            let nodeXposition = node.position.x
            nodeOriginalXArray.append(nodeXposition)
            let nodeYposition = node.position.y
            nodeOriginalYArray.append(nodeYposition)
        }
    }
    
    func createBall(withImage: String)
    {
        if !self.ballFlag
        {
            self.setBallProperties(withImage: withImage)
            self.ballFlag = true
        }
    }
    
    func setBallProperties(withImage image: String)
    {
        let textureBall : SKTexture! = SKTexture(imageNamed: image)
        let ballSize: CGSize = textureBall.size()
        
        ball = SKShapeNode(circleOfRadius: ballSize.width / 2)
        ball!.fillTexture = textureBall
        ball!.fillColor = SKColor.white
        ball!.strokeColor = SKColor.clear
        ball!.position = (spawnImage?.position)!
        
        ball!.physicsBody = SKPhysicsBody(circleOfRadius: ballSize.width / 2)
        ball!.physicsBody!.affectedByGravity = true
        ball!.physicsBody!.categoryBitMask = 0b0001
        ball!.physicsBody!.collisionBitMask = 0b10011
        
        self.addChild(ball!)
    }
    
    
    func cleanUpLevel ()
    {
        self.removeAllChildren()
        
        ball = nil
        ballFlag = false
        
        arrayOfLines = Array()
        arrayOfNodes = Array()
        nodeOriginalXArray = []
        nodeOriginalYArray = []
        arrayOfStars = Array()
        starsOriginalXArray = Array()
        starsOriginalYArray = Array()
        arrayOfStarsHit = []
        
        self.createLevel(levelNumber: level)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        splineShapeNode = nil
        
        let touch = touches.first
        var point = touch?.location(in: scrollView)
        point!.x = point!.x - ((self.view?.frame.width)! / 2) - scrollView!.contentOffset.x
        point!.y = (point!.y - ((self.view?.frame.height)! / 2)) * (-1) + scrollView!.contentOffset.y
        
        mutablePath = CGMutablePath()
        mutablePath.move(to: point!)
        splineShapeNode = SKShapeNode(path: mutablePath)
        splineShapeNode.strokeColor = SKColor.black
        self.addChild(splineShapeNode)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        var point = touch?.location(in: scrollView)
        point!.x = point!.x - ((self.view?.frame.width)! / 2) - scrollView!.contentOffset.x
        point!.y = (point!.y - ((self.view?.frame.height)! / 2)) * (-1) + scrollView!.contentOffset.y
        
        mutablePath.addLine(to: point!)
        splineShapeNode.path = mutablePath
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        splineShapeNode.physicsBody = SKPhysicsBody(edgeChainFrom: splineShapeNode.path!)
        splineShapeNode.physicsBody?.affectedByGravity = false
        arrayOfLines.append(splineShapeNode)
        linesOriginalXArray.append(splineShapeNode.position.x + scrollView!.contentOffset.x)
        linesOriginalYArray.append(splineShapeNode.position.y - scrollView!.contentOffset.y)
        adjustContent(scrollView: scrollView!)
       
    }
    
    func hideScrollView ()
    {
        self.scrollView?.isHidden = true
    }
    
    func showScrollView ()
    {
        self.scrollView?.isHidden = false
    }
    
}

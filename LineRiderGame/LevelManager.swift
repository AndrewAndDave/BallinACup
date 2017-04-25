//
//  LevelManager.swift
//  LineRiderGame
//
//  Created by David Guichon on 2017-04-23.
//  Copyright © 2017 KSG. All rights reserved.
//

import Foundation
import UIKit

class LevelManager
{    
    var currentLevel: Level?
    var levelSelected: Int!
    
    var highestLevel: Int!

    init()
    {
        if highestLevel == nil
        {
            highestLevel = 1
        }
        
        if levelSelected == nil
        {
            levelSelected = 0
        }
        currentLevel = getNextLevel()
    }

    func getNextLevel() -> (Level)
    {
         let level = Level()
        
        levelSelected = levelSelected + 1
        
        switch levelSelected
        {
            
        case 1:
            
            level.contentSizeWidth = 1000
            level.contentSizeHeight = 1000
            level.imageName = "Group 1 Background"
            level.spawnMarkerX = -292
            level.spawnMarkerY = 120
            level.basketX = 100
            level.basketY = 0
            
            break
            
        case 2:
            
            level.contentSizeWidth = 1000
            level.contentSizeHeight = 1000
            level.imageName = "Group 1 Background"
            level.spawnMarkerX = -292
            level.spawnMarkerY = 120
            level.basketX = 100
            level.basketY = -100
            level.stars = [(x: -263, y: 34),(x: -318, y: -33),(x: -138, -84)]
            
            break
            
        case 3:
            
            level.contentSizeWidth = 1000
            level.contentSizeHeight = 1000
            level.spawnMarkerX = 1
            level.spawnMarkerY = 1
            level.basketX = 1
            level.basketY = 1
            level.stars = [(x: -263, y: 34),(x: -318, y: -33),(x: -138, -84)]

            
            break
            
        case 4: break
            
        case 5: break
            
        case 6: break
            
        case 7: break
            
        case 8: break
            
        case 9: break
            
        case 10: break
            
        case 12: break
            
        case 13: break
            
        default: break
            
        }
        return level
    }
}

//PASS THE NECESSARY VALUES AS ARGUMENTS INTO A CUSTOM INITIALIZER FOR THE LEVEL
//THE LEVEL SHOULD BE PASSED AROUND WITH ANY INFORMATION NECESSARY TO BE HELD ABOUT THE CURRENT LEVEL
//HAVE TO MAKE SURE THAT THERE IS NO MEMORY LEAK
class Level
{
    var contentSizeWidth: CGFloat?
    var contentSizeHeight: CGFloat?
    
    var imageName: String?
    
    var spawnMarkerX: CGFloat?
    var spawnMarkerY: CGFloat?
    
    var basketX: CGFloat?
    var basketY: CGFloat?
    
    var stars: [(x: CGFloat, y: CGFloat)] = []
}

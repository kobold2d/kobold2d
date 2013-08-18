//
//  cpCCSprite+PhysicsEditor.h
//  Cocos2d-Chipmunk
//
//  Created by Andreas Low on 07.07.11.
//  Copyright 2011 codeandweb.de. All rights reserved.
//

#import "cpCCSprite.h"

@interface cpCCSprite (PhysicsEditor)

/*!
 * Create a sprite with image file and body 
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param fileName name of the file to load
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
-(id) initWithFile:(NSString*)fileName 
          bodyName:(NSString*)bodyName
      spaceManager:(SpaceManager*)spaceManager;

/*!
 * Create a sprite with sprite frame and body 
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param spriteFrame pointer to a sprite frame
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame 
                 bodyName:(NSString*)bodyName
             spaceManager:(SpaceManager*)spaceManager;

/*!
 * Create a sprite with sprite frame name and body 
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param spriteFrameName name of a sprite frame
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
-(id) initWithSpriteFrameName:(NSString*)spriteFrameName 
                     bodyName:(NSString*)bodyName    
                 spaceManager:(SpaceManager*)spaceManager;

/*!
 * Create a sprite with image file and body 
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param fileName name of the file to load
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
+(id) spriteWithFile:(NSString*)file 
            bodyName:(NSString*)bodyName
        spaceManager:(SpaceManager*)spaceManager;


/*!
 * Create a sprite with sprite frame and body 
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param spriteFrame pointer to a sprite frame
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
+(id) spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame 
                   bodyName:(NSString*)bodyName
               spaceManager:(SpaceManager*)spaceManager;

/*!
 * Create a sprite with sprite frame name and body 
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param spriteFrameName name of a sprite frame
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
+(id) spriteWithSpriteFrameName:(NSString*)spriteFrameName 
                       bodyName:(NSString*)bodyName
                   spaceManager:(SpaceManager*)spaceManager;

/*!
 * Create a sprite with sprite frame name and body 
 *
 * This function uses the same name for the sprite frame and the
 * body shape.
 * 
 * You can use this if you also use TexturePacker http://www.texturepacker.com
 * and activate "Trim sprite names". In this case the .png ending
 * is removed from the sprite's name so that both the sprite and the 
 * body shape use the same name.
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param spriteFrameName name of a sprite frame
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
+(id) spriteWithBodyName:(NSString*)bodyName
            spaceManager:(SpaceManager*)spaceManager;

/*!
 * Create a sprite with sprite frame name and body 
 *
 * This function uses the same name for the sprite frame and the
 * body shape.
 * 
 * You can use this if you also use TexturePacker http://www.texturepacker.com
 * and activate "Trim sprite names". In this case the .png ending
 * is removed from the sprite's name so that both the sprite and the 
 * body shape use the same name.
 *
 * GCpShapeCache must be initialised before using this funciton.
 *
 * @param spriteFrameName name of a sprite frame
 * @param bodyName name of the body as defined in PhysicsEditor
 * @param spaceManager spaceManager to add the body to
 *
 * @result cpCCSprite
 */
-(id) initWithBodyName:(NSString*)bodyName
          spaceManager:(SpaceManager*)spaceManager;

@end

//
//  cpCCSprite+PhysicsEditor.m
//  Cocos2d-Chipmunk
//
//  Created by Andreas Low on 07.07.11.
//  Copyright 2011 codeandweb.de. All rights reserved.
//

#import "cpCCSprite+PhysicsEditor.h"
#import "GCpShapeCache.h"

@implementation cpCCSprite (PhysicsEditor)

-(void) _bodySetup:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    GCpShapeCache *cache = [GCpShapeCache sharedShapeCache];
    
    self.anchorPoint = [cache anchorPointForShape:bodyName];
    cpBody *body = [cache createBodyWithName:bodyName 
                                     inSpace:spaceManager.space 
                                    withData:self];

    self.body = body;
    self.spaceManager = spaceManager;
}

-(id) initWithFile:(NSString*)file bodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    self = [super initWithFile:file];
    if(self)
    {
        [self _bodySetup:bodyName spaceManager:spaceManager];
    }
    return self;
}

-(id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame bodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    self = [super initWithSpriteFrame:spriteFrame];
    if(self)
    {
        [self _bodySetup:bodyName spaceManager:spaceManager];
    }
    return self; 
}

-(id) initWithSpriteFrameName:(NSString*)spriteFrameName bodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    self = [super initWithSpriteFrameName:spriteFrameName];
    if(self)
    {
        [self _bodySetup:bodyName spaceManager:spaceManager];
    }
    return self;     
}

-(id) initWithBodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    return [self initWithSpriteFrameName:bodyName bodyName:bodyName spaceManager:spaceManager];
}

+(id) spriteWithFile:(NSString*)fileName bodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    return [[[self alloc] initWithFile:fileName bodyName:bodyName spaceManager:spaceManager] autorelease];        
}

+(id) spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame bodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    return [[[self alloc] initWithSpriteFrame:spriteFrame bodyName:bodyName spaceManager:spaceManager] autorelease];    
}

+(id) spriteWithSpriteFrameName:(NSString*)spriteFrameName bodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName bodyName:bodyName spaceManager:spaceManager] autorelease];
}

+(id) spriteWithBodyName:(NSString*)bodyName spaceManager:(SpaceManager*)spaceManager
{
    return [[[self alloc] initWithBodyName:bodyName spaceManager:spaceManager] autorelease];
}

@end

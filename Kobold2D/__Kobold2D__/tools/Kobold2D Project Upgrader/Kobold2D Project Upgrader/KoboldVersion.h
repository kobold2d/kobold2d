//
//  KoboldVersion.h
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KoboldVersion : NSObject <NSXMLParserDelegate>
{
	NSMutableArray* projects;
	NSString* name;
	NSString* path;
	NSString* destinationPath;
	NSString* versionString;
	
	NSString* currentWorkspacePath;
}

@property (readonly) NSMutableArray* projects;
@property (copy) NSString* name;
@property (copy) NSString* path;
@property (copy) NSString* destinationPath;
@property (copy) NSString* versionString;


-(id) initWithPath:(NSString*)aPath destinationPath:(NSString*)aDestinationPath;

-(NSComparisonResult) compareWith:(id)object;


@end

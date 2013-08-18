/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** KKScreenshot allows you to create a screenshot of the entire screen or individual layers. */
@interface KKScreenshot : NSObject

/** This returns the screenshot path (including filename) for a given file. The path will point to the file
 in the app's documents directory. 
 
 Note that screenshotWithStartNode uses this method to create the full path, you should NOT pass the path returned
 by screenshotPathForFile to screenshotWithStartNode. But you do need the full path if you want to remove a previously
 loaded screenshot file texture from CCTextureCache, because the screenshot file will be cached in CCTextureCache
 not by its filename but by its full path.
 */
+(NSString*) screenshotPathForFile:(NSString*)file;

/** This will render all of the nodes in the hierarchy starting with startNode to the given filename and returns
 an autoreleased instance of the created CCRenderTexture. The filename is created in the app's documents directory,
 according to the path provided by screenshotPathForFile.
 
 Note: on Mac OS X, the screenshot will not be saved to file, you will have to save the render texture manually
 because CCRenderTexture currently does not support the saveBuffer method on Mac OS X.
 */
+(CCRenderTexture*) screenshotWithStartNode:(CCNode*)startNode filename:(NSString*)filename;

/** Same as above but only returns the CCRenderTexture, doesn't save to file. This is faster if you don't need the screenshot as an image file. */
+(CCRenderTexture*) screenshotWithStartNode:(CCNode*)startNode;

@end

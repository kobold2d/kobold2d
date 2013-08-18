/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"

/** Access to configuration values loaded from config.lua - individual branches of the configuration values tree (lua table) can be selected and traversed. */
@interface KKConfig : NSObject
{
@private
	NSDictionary* dict;
	NSDictionary* selectedDict;
}

/** Called once by Kobold2D at system startup to run the config.lua script. Expects a table to be returned. */
+(void) loadConfigLua;

/** Dumps the entire config.lua table (actually, it's Objective-C representation as a NSDictionary) to the console, for debugging purposes. */
+(void) dumpConfigLua;

/** Select the part of the Lua table given by the key respectively key path (using dot notation). Returns YES if the path exists, otherwise return NO.

 The key path can be written just like you would access a nested Lua table: @"MyParams.Player.AnimationFrames".
 Once a part of the table is "selected" you can then use the "ForKey" methods to read individual entries
 of that part of the table by using one of the xxxForKey methods. */
+(BOOL) selectKeyPath:(const NSString* const)keyPath;

/** Selects the root of the table. */
+(void) selectRootPath;

/** Get the Lua table dictionary from the currently selected key path. */
+(NSDictionary*) dictionaryForKey:(NSString*)key;
/** Get the string from the currently selected key path. */
+(NSString*) stringForKey:(NSString*)key;
/** Get the NSNumber from the currently selected key path. */
+(NSNumber*) numberForKey:(NSString*)key;
/** Get the float from the currently selected key path. */
+(float) floatForKey:(NSString*)key;
/** Get the int from the currently selected key path. */
+(int) intForKey:(NSString*)key;
/** Get the bool (as int) from the currently selected key path. */
+(BOOL) boolForKey:(NSString*)key;

/** Directly sets the target's matching properties from the path in the config table. 
 Only float, int, BOOL or NSString properties are supported. 
 All properties must match the corresponding Lua type. Does not change the selected key path. */
+(void) injectPropertiesFromKeyPath:(const NSString* const)keyPath target:(id)target;

@end

/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "cocos2d-extensions.h"
#import "luawax.h"

#define BEGIN_STACK_MODIFY(L) int __startStackIndex = lua_gettop((L));

#define END_STACK_MODIFY(L, i) while(lua_gettop((L)) > (__startStackIndex + (i))) lua_remove((L), __startStackIndex + 1);

#define CLEAR_STACK(L) lua_pop((L), lua_gettop((L)));

void lua_setup();

inline lua_State *currentLuaState();

// Debug Helpers
void lua_printStack(lua_State *L);
void lua_printStackAt(lua_State *L, int i);
//void wax_printTable(lua_State *L, int t);
//void wax_log(int flag, NSString *format, ...);

//int wax_errorFunction(lua_State *L);
//int wax_pcall(lua_State *L, int argumentCount, int returnCount);


/** Static class containing various Lua related helper methods. */
@interface KKLua : NSObject 
{
@private

}

/** Runs the Lua script file. File is a filename with or without path to the file, and with extension. 
 Returns YES if the execution was successful and NO if it failed. Note that this is different from Lua, 
 where a return value of 0 indicates success and 1 or higher indicates an error. But YES == success
 is more natural for Objective-C programmers.*/
+(id) doFile:(NSString*)aFile;

/** Like doFile but allows to add some Lua code dynamically either before or after the contents of the file, or both. */
+(id) doFile:(NSString *)aFile prefixCode:(NSString*)aPrefix suffixCode:(NSString*)aSuffix;

/** Runs the Lua code passed in as string.
 Returns YES if the execution was successful and NO if it failed. Note that this is different from Lua, 
 where a return value of 0 indicates success and 1 or higher indicates an error. But YES == success
 is more natural for Objective-C programmers.*/
+(id) doString:(NSString*)aString;

/** Runs the given Lua script file and expects it to return a table. The returned table is then parsed
 into a hierarchy of NSMutableDictionary objects. The hierarchy of dictionaries now allows you to navigate
 the Lua table using regular Objective-C syntax. The returned NSMutableDictionary is set to autorelease. */
+(NSDictionary*) loadLuaTableFromFile:(NSString*)aFile;

/*
 Returns the Class with the same name of a Lua script. First, it checks if the class already exists, and if so it returns the existing class.
 Otherwise it will doFile the lua script scriptName.lua and create a waxClass with the given superClass to create this class. On the next call the class
 will already exist and the script isn't called a second time. */
//+(Class) classFromLuaScriptWithName:(NSString*)scriptName superClass:(NSString*)superClass;

/** Logs the most recent Lua error by getting the error message string from the stack index -1 and displaying it. */
+(void) logLuaError;

/** Logs a Lua error with a custom message. */
+(void) logLuaErrorWithMessage:(NSString*)aMessage;

@end

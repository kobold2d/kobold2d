/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKLua.h"

#if KK_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif

@interface KKLua (PrivateMethods)
+(void) internalLoadSubTableWithKey:(NSString*)aKey luaState:(lua_State*)theLuaState dictionary:(NSMutableDictionary*)aDictionary;
+(NSMutableDictionary*) internalRecursivelyLoadTable:(lua_State*)theLuaState index:(int)anIndex;

typedef enum
{
	kStructType_INVALID = 0,
	kStructTypePoint,
	kStructTypeSize,
	kStructTypeRect,
} EStructTypes;
@end


lua_State *currentLuaState() 
{
    static lua_State *L;    
    if (!L) L = lua_open();
    
    return L;
}

int lua_panic(lua_State *L) 
{
	printf("Lua panicked and quit, message: %s\n", luaL_checkstring(L, -1));
	exit(EXIT_FAILURE);
}


lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf);

void lua_setup() 
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager changeCurrentDirectoryPath:[[NSBundle mainBundle] bundlePath]];
    
    lua_State *L = currentLuaState();
	lua_atpanic(L, &lua_panic);
    
    luaL_openlibs(L); 
}

void lua_printStack(lua_State *L) 
{
    int i;
    int top = lua_gettop(L);
    
    for (i = 1; i <= top; i++) 
	{
        printf("%d: ", i);
        lua_printStackAt(L, i);
        printf("\n");
    }
    
    printf("\n");
}

void lua_printStackAt(lua_State *L, int i)
{
    int t = lua_type(L, i);
    printf("(%s) ", lua_typename(L, t));
    
    switch (t)
	{
        case LUA_TSTRING:
            printf("'%s'", lua_tostring(L, i));
            break;
        case LUA_TBOOLEAN:
            printf(lua_toboolean(L, i) ? "true" : "false");
            break;
        case LUA_TNUMBER:
            printf("'%g'", lua_tonumber(L, i));
            break;
        default:
            printf("%p", lua_topointer(L, i));
            break;
    }
}

/*
void wax_printTable(lua_State *L, int t) {
    // table is in the stack at index 't'
    
    if (t < 0) t = lua_gettop(L) + t + 1; // if t is negative, we need to normalize
	if (t <= 0 || t > lua_gettop(L)) {
		printf("%d is not within stack boundries.\n", t);
		return;
	}
	else if (!lua_istable(L, t)) {
		printf("Object at stack index %d is not a table.\n", t);
		return;
	}
	
	lua_pushnil(L);  // first key
    while (lua_next(L, t) != 0) {
        wax_printStackAt(L, -2);
        printf(" : ");
        wax_printStackAt(L, -1);
        printf("\n");
		
        lua_pop(L, 1); // remove 'value'; keeps 'key' for next iteration
    }
}
*/

/*
void wax_log(int flag, NSString *format, ...) {
    if (flag & LOG_FLAGS) {
        va_list args;
        va_start(args, format);
        NSString *output = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
        printf("%s\n", [output UTF8String]);
        va_end(args);
    }
}
*/

/*
int wax_errorFunction(lua_State *L) {
    lua_getfield(L, LUA_GLOBALSINDEX, "debug");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        return 1;
    }
    
    lua_getfield(L, -1, "traceback");
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 2);
        return 1;
    }    
    lua_remove(L, -2); // Remove debug
    
    lua_pushvalue(L, -2); // Grab the error string and place it on the stack
    
    lua_call(L, 1, 1);
    lua_remove(L, -2); // Remove original error string
    
    return 1;
}

int wax_pcall(lua_State *L, int argumentCount, int returnCount) {
    lua_pushcclosure(L, wax_errorFunction, 0);
    int errorFuncStackIndex = lua_gettop(L) - (argumentCount + 1); // Insert error function before arguments
    lua_insert(L, errorFuncStackIndex);
    
    return lua_pcall(L, argumentCount, returnCount, errorFuncStackIndex);
}
*/


@implementation KKLua

+(void) logLuaError
{
	lua_State* L = currentLuaState();
	int top = lua_gettop(L);
	
	NSString* message = nil;
	if (lua_isstring(L, top))
	{
		const char* str = luaL_checkstring(L, top);
		message = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
		lua_pop(L, 1);
	}
	else
	{
		message = @"(error without message)";
	}

	NSLog(@"Lua error: %@", message);
	
#if KK_PLATFORM_IOS
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Lua Error" 
													message:message 
												   delegate:nil
										  cancelButtonTitle:@"$#@&%!"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
#elif KK_PLATFORM_MAC
	NSAlert* alert = [NSAlert alertWithMessageText:@"Lua Error"
									 defaultButton:@"$#@&%!" 
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:@"%@", message];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert runModal];
#endif
}

+(void) logLuaErrorWithMessage:(NSString*)aMessage
{
	lua_State* L = currentLuaState();
	int top = lua_gettop(L);
	
	NSString* originalMessage = nil;
	if (lua_isstring(L, top))
	{
		const char* str = luaL_checkstring(L, top);
		originalMessage = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
		lua_pop(L, 1);
		
		aMessage = [NSString stringWithFormat:@"%@ (Lua error message: %@)", aMessage, originalMessage];
	}

	lua_pushstring(L, [aMessage cStringUsingEncoding:NSUTF8StringEncoding]);
	[KKLua logLuaError];
}

+(id) returnValue
{
	id retval = nil;

	/*
	if (lua_istable(currentLuaState(), 1))
	{
		id* objc = wax_copyToObjc(currentLuaState(), @encode(id), 1, nil);
		retval = *objc;
		lua_pop(currentLuaState(), 1);
		wax_printStack(currentLuaState());
	}
	 */
	
	return retval;
}

+(id) doFile:(NSString*)aFile
{
	NSAssert1(aFile != nil, @"%@: file is nil", NSStringFromSelector(_cmd));
	
	aFile = [[NSBundle mainBundle] pathForResource:[aFile lastPathComponent]
											ofType:nil
									   inDirectory:[aFile stringByDeletingLastPathComponent]];
	
	// fix for unit tests
	if ([[NSFileManager defaultManager] fileExistsAtPath:aFile] == NO)
	{
		NSBundle* testBundle = [NSBundle bundleForClass:NSClassFromString(@"KoboldScript_Test")];
		aFile = [testBundle pathForResource:aFile ofType:nil];
	}
	
	const char* cfile = [aFile cStringUsingEncoding:NSUTF8StringEncoding];
	NSAssert1(cfile != nil, @"%@: C file is nil, possible encoding failure", NSStringFromSelector(_cmd));
	
	BOOL success = (luaL_dofile(currentLuaState(), cfile) == 0);
	if (success == NO)
	{
		[KKLua logLuaError];
	}
	
	return [self returnValue];
}

+(id) doFile:(NSString *)aFile prefixCode:(NSString*)aPrefix suffixCode:(NSString*)aSuffix
{
	NSAssert1(aFile != nil, @"%@: file is nil", NSStringFromSelector(_cmd));

	aFile = [[NSBundle mainBundle] pathForResource:[aFile lastPathComponent]
											ofType:nil
									   inDirectory:[aFile stringByDeletingLastPathComponent]];

	if (aPrefix == nil)
	{
		aPrefix = @"";
	}
	if (aSuffix == nil)
	{
		aSuffix = @"";
	}
	
	NSString* script = [NSString stringWithFormat:@"%@;%@\n%@", aPrefix, [NSString stringWithContentsOfFile:aFile encoding:NSUTF8StringEncoding error:nil], aSuffix];
	[KKLua doString:script];

	return [self returnValue];
}

+(id) doString:(NSString*)aString
{
	NSAssert1(aString != nil, @"%@: string is nil", NSStringFromSelector(_cmd));

	const char* cstring = [aString cStringUsingEncoding:NSUTF8StringEncoding];
	NSAssert1(cstring != nil, @"%@: C string is nil, possible encoding failure", NSStringFromSelector(_cmd));

	BOOL success = (luaL_dostring(currentLuaState(), cstring) == 0);
	if (success == NO)
	{
		[KKLua logLuaError];
	}
	
	return [self returnValue];
}

+(float) getFloatFromTable:(lua_State*)state index:(int)index
{
	lua_pushinteger(state, index);
	lua_gettable(state, -2);
	float f = (float)lua_tonumber(state, -1);
	lua_pop(state, 1);
	return f;
}

+(void) internalLoadSubTableWithKey:(NSString*)aKey
                           luaState:(lua_State*)theLuaState
                         dictionary:(NSMutableDictionary*)aDictionary
{
	// check if the table contains a "magic marker"
	lua_getfield(theLuaState, -1, "structType");
	int structType = (int)lua_tointeger(theLuaState, -1);
	lua_pop(theLuaState, 1);

	// create the appropriate NSValue type
	switch (structType)
	{
		case kStructTypePoint:
		{
			float x = [KKLua getFloatFromTable:theLuaState index:1];
			float y = [KKLua getFloatFromTable:theLuaState index:2];
#ifdef KK_PLATFORM_IOS
			[aDictionary setObject:[NSValue valueWithCGPoint:CGPointMake(x, y)] forKey:aKey];
#else
			[aDictionary setObject:[NSValue valueWithPoint:NSMakePoint(x, y)] forKey:aKey];
#endif
			break;
		}
		case kStructTypeSize:
		{
			float width = [KKLua getFloatFromTable:theLuaState index:1];
			float height = [KKLua getFloatFromTable:theLuaState index:2];
#ifdef KK_PLATFORM_IOS
			[aDictionary setObject:[NSValue valueWithCGSize:CGSizeMake(width, height)] forKey:aKey];
#else
			[aDictionary setObject:[NSValue valueWithSize:NSMakeSize(width, height)] forKey:aKey];
#endif
			break;
		}
		case kStructTypeRect:
		{
			float x = [KKLua getFloatFromTable:theLuaState index:1];
			float y = [KKLua getFloatFromTable:theLuaState index:2];
			float width = [KKLua getFloatFromTable:theLuaState index:3];
			float height = [KKLua getFloatFromTable:theLuaState index:4];
#ifdef KK_PLATFORM_IOS
			[aDictionary setObject:[NSValue valueWithCGRect:CGRectMake(x, y, width, height)] forKey:aKey];
#else
			[aDictionary setObject:[NSValue valueWithRect:NSMakeRect(x, y, width, height)] forKey:aKey];
#endif
			break;
		}
			
		default:
		case kStructType_INVALID:
		{
			// assume it's a user table, recurse into it
			NSMutableDictionary* tableDict = [KKLua internalRecursivelyLoadTable:theLuaState index:-1];
			if (tableDict != nil)
			{
				[aDictionary setObject:tableDict forKey:aKey];
			}
			break;
		}
	}
}

+(NSMutableDictionary*) internalRecursivelyLoadTable:(lua_State*)theLuaState index:(int)anIndex
{
	NSString* error = nil;
	NSMutableDictionary* dict = nil;

	if (lua_istable(theLuaState, anIndex))
	{
		dict = [NSMutableDictionary dictionaryWithCapacity:10];
		
		lua_pushnil(theLuaState);  // first key
		while (lua_next(theLuaState, -2) != 0)
		{
			/*
			CCLOG(@"%@ - %@\n",
				  [NSString stringWithCString:lua_typename(state, lua_type(state, -2)) encoding:NSUTF8StringEncoding],
				  [NSString stringWithCString:lua_typename(state, lua_type(state, -1)) encoding:NSUTF8StringEncoding]);
			 */
			
			NSString* key = nil;
			if (lua_isnumber(theLuaState, -2))
			{
				int number = (int)lua_tonumber(theLuaState, -2);
				key = [NSString stringWithFormat:@"%i", number];
			}
			else if (lua_isstring(theLuaState, -2))
			{
				key = [NSString stringWithCString:lua_tostring(theLuaState, -2) encoding:NSUTF8StringEncoding];
			}
			else
			{
				error = @"key in table is neither string nor number!";
				break;
			}
			
			int luaTypeOfValue = lua_type(theLuaState, -1);
			switch (luaTypeOfValue)
			{
				case LUA_TNUMBER:
					[dict setObject:[NSNumber numberWithFloat:(float)lua_tonumber(theLuaState, -1)] forKey:key];
					break;
				case LUA_TSTRING:
					[dict setObject:[NSString stringWithCString:lua_tostring(theLuaState, -1) encoding:NSUTF8StringEncoding] forKey:key];
					break;
				case LUA_TBOOLEAN:
					[dict setObject:[NSNumber numberWithBool:lua_toboolean(theLuaState, -1)] forKey:key];
					break;
				case LUA_TTABLE:
				{
					[KKLua internalLoadSubTableWithKey:key luaState:theLuaState dictionary:dict];
					break;
				}

				default:
					CCLOG(@"Unknown value type %i in table ignored.", luaTypeOfValue);
					break;
			}
			
			lua_pop(theLuaState, 1);
		}
	}
	else
	{
		error = @"not a Lua table!";
	}

	if (error != nil)
	{
		NSLog(@"\n\nERROR in %@: %@\n\n", NSStringFromSelector(_cmd), error);
    }

	return dict;
}

+(NSDictionary*) loadLuaTableFromFile:(NSString*)aFile
{
	NSMutableDictionary* dict = nil;
	[KKLua doFile:aFile];
		
	if (lua_istable(currentLuaState(), -1))
	{
		dict = [KKLua internalRecursivelyLoadTable:currentLuaState() index:-1];
		//LOG_EXPR(dict);
	}
	else
	{
		NSString* error = [NSString stringWithCString:lua_tostring(currentLuaState(), -1) encoding:NSUTF8StringEncoding];
		NSLog(@"\n\nERROR in %@: %@\n\n", NSStringFromSelector(_cmd), error);
	}
	
	lua_pop(currentLuaState(), 1);

	return dict;
}

/*
+(Class) classFromLuaScriptWithName:(NSString*)scriptName superClass:(NSString*)superClass
{
	Class scriptClass = nil;
	if (scriptName)
	{
		scriptClass = NSClassFromString(scriptName);

		// create the Class object if needed
		if (scriptClass == nil)
		{
			NSString* scriptFile = [NSString stringWithFormat:@"%@.lua", scriptName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:scriptFile])
			{
				// The waxClass line must be prefixed to the same Lua pcall, otherwise it won't register the file's functions as part of the class.
				// This is why a simple doString of waxClass followed by a doFile of the scriptFile won't work.
				NSString* waxClass = [NSString stringWithFormat:@"waxClass{'%@', %@}", scriptName, superClass];
				[KKLua doFile:scriptFile prefixCode:waxClass suffixCode:nil];
				
				scriptClass = NSClassFromString(scriptName);
				NSAssert2(scriptClass != nil, @"%@ - could not create class from script '%@'", NSStringFromSelector(_cmd), scriptFile);
			}
			else
			{
				CCLOG(@"%@ - lua script file '%@' not found in bundle!", NSStringFromSelector(_cmd), scriptFile);
			}
		}
	}

	return scriptClass;
}
*/

@end

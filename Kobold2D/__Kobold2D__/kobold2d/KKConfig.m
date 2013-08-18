/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "KKConfig.h"
#import "KKLua.h"

@interface KKConfig (Private)
-(void) selectRootPath;
@end

@implementation KKConfig

static KKConfig *instanceOfConfig;

#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfConfig == nil, @"Attempted to allocate a second instance of the singleton: Config");
		instanceOfConfig = [[super alloc] retain];
		return instanceOfConfig;
	}
	
	// to avoid compiler warning
	return nil;
}

+(KKConfig*) sharedConfig
{
	@synchronized(self)
	{
		if (instanceOfConfig == nil)
		{
			instanceOfConfig = [[KKConfig alloc] init];
		}
		
		return instanceOfConfig;
	}
	
	// to avoid compiler warning
	return nil;
}

#pragma mark Init / dealloc

-(id) init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	
	selectedDict = nil;
	[dict release];
	
	[instanceOfConfig release];
	instanceOfConfig = nil;

	[super dealloc];
}

#pragma mark Load config

-(void) loadConfigLua
{
	[dict release];
	dict = [[KKLua loadLuaTableFromFile:@"config.lua"] retain];
	NSAssert(dict != nil, @"ERROR loading config.lua!");
	
	[self selectRootPath];
}

+(void) loadConfigLua
{
	[[KKConfig sharedConfig] loadConfigLua];
}

-(void) dumpConfigLua
{
	CCLOG(@"=============== CONFIG.LUA =============== CONFIG.LUA =============== CONFIG.LUA =============== CONFIG.LUA ===============");
	CCLOG(@"%@", dict);
	CCLOG(@"=============== CONFIG.LUA =============== CONFIG.LUA =============== CONFIG.LUA =============== CONFIG.LUA ===============");
}

+(void) dumpConfigLua
{
	[[KKConfig sharedConfig] dumpConfigLua];
}

#pragma mark value for key

-(NSDictionary*) dictionaryForKey:(NSString*)key
{
	NSDictionary* dictionary = nil;
	id object = [selectedDict objectForKey:key];
	
	BOOL isDictionary = [object isKindOfClass:[NSDictionary class]];
	if (isDictionary)
	{
		dictionary = (NSDictionary*)object;
	}
	else
	{
		//CCLOG(@"key %@ does not exist or is not a dictionary (table) object! selectedDict: %@", key, selectedDict);
	}
	
	return dictionary;
}

-(NSString*) stringForKey:(NSString*)key
{
	NSString* string = nil;
	id object = [selectedDict objectForKey:key];
	
	BOOL isString = [object isKindOfClass:[NSString class]];
	if (isString)
	{
		string = (NSString*)object;
	}
	else
	{
		//CCLOG(@"key %@ does not exist or is not a string object!", key);
	}

	return string;
}

-(NSNumber*) numberForKey:(NSString*)key
{
	NSNumber* number = nil;
	id object = [selectedDict objectForKey:key];
	
	BOOL isNumber = [object isKindOfClass:[NSNumber class]];
	if (isNumber)
	{
		number = (NSNumber*)object;
	}
	else
	{
		//CCLOG(@"key %@ does not exist or is not a number object!", key);
	}
	
	return number;
}

+(NSDictionary*) dictionaryForKey:(NSString*)key
{
	return [[KKConfig sharedConfig] dictionaryForKey:key];
}

+(NSString*) stringForKey:(NSString*)key
{
	return [[KKConfig sharedConfig] stringForKey:key];
}

+(NSNumber*) numberForKey:(NSString*)key
{
	return [[KKConfig sharedConfig] numberForKey:key];
}

+(float) floatForKey:(NSString*)key
{
	return [[[KKConfig sharedConfig] numberForKey:key] floatValue];
}

+(int) intForKey:(NSString*)key
{
	return [[[KKConfig sharedConfig] numberForKey:key] intValue];
}

+(BOOL) boolForKey:(NSString*)key
{
	return [[[KKConfig sharedConfig] numberForKey:key] boolValue];
}

#pragma mark Select table

-(void) selectRootPath
{
	selectedDict = dict;
}

+(void) selectRootPath
{
	[[KKConfig sharedConfig] selectRootPath];
}

-(BOOL) selectKeyPath:(const NSString* const)keyPath
{
	BOOL pathExists = YES;
	[self selectRootPath];

	NSArray* path = [keyPath componentsSeparatedByString:@"."];
	for (NSString* key in path)
	{
		selectedDict = [self dictionaryForKey:key];
		
		if (selectedDict == nil)
		{
			CCLOG(@"keyPath '%@': component '%@' not found or it's not a table!", keyPath, key);
			pathExists = NO;
			[self selectRootPath];
			break;
		}
	}
	
	return pathExists;
}

+(BOOL) selectKeyPath:(NSString*)keyPath
{
	return [[KKConfig sharedConfig] selectKeyPath:keyPath];
}

#pragma mark Inject KeyPath directly into Properties

-(void) setInvocationArgument:(NSInvocation*)invocation value:(id)value signature:(NSMethodSignature*)sig
{
	const int argIndex = 2;

	if ([value isKindOfClass:[NSNumber class]])
	{
		NSString* argType = [NSString stringWithCString:[sig getArgumentTypeAtIndex:argIndex] encoding:NSASCIIStringEncoding];
		if ([argType isEqualToString:@"f"])
		{
			float number = [(NSNumber*)value floatValue];
			[invocation setArgument:&number atIndex:argIndex];
		}
		else if ([argType isEqualToString:@"i"])
		{
			int number = [(NSNumber*)value intValue];
			[invocation setArgument:&number atIndex:argIndex];
		}
		else if ([argType isEqualToString:@"c"] || [argType isEqualToString:@"B"])
		{
			BOOL flag = [(NSNumber*)value boolValue];
			[invocation setArgument:&flag atIndex:argIndex];
		}
		else if ([argType isEqualToString:@"d"])
		{
			double number = [(NSNumber*)value doubleValue];
			[invocation setArgument:&number atIndex:argIndex];
		}
	}
	else if ([value isKindOfClass:[NSValue class]])
	{
		NSValue* val = (NSValue*)value;
		NSString* type = [NSString stringWithCString:[val objCType] encoding:NSASCIIStringEncoding];
		if ([type hasPrefix:@"{CGPoint="] || [type hasPrefix:@"{_NSPoint="])
		{
#ifdef KK_PLATFORM_IOS
			CGPoint point = [val CGPointValue];
#else
			NSPoint point = [val pointValue];
#endif
			[invocation setArgument:&point atIndex:argIndex];
		}
		else if ([type hasPrefix:@"{CGSize="] || [type hasPrefix:@"{_NSSize="])
		{
#ifdef KK_PLATFORM_IOS
			CGSize size = [val CGSizeValue];
#else
			NSSize size = [val sizeValue];
#endif
			[invocation setArgument:&size atIndex:argIndex];
		}
		else if ([type hasPrefix:@"{CGRect="] || [type hasPrefix:@"{_NSRect="])
		{
#ifdef KK_PLATFORM_IOS
			CGRect rect = [val CGRectValue];
#else
			NSRect rect = [val rectValue];
#endif
			[invocation setArgument:&rect atIndex:argIndex];
		}
		else
		{
			CCLOG(@"unsupported NSValue type '%@' = '%@' - skipped!", [value class], type);
		}
	}
	else if ([value isKindOfClass:[NSString class]])
	{
		NSString* string = (NSString*)value;
		[invocation setArgument:&string atIndex:argIndex];
	}
	else
	{
		CCLOG(@"unsupported value type '%@' = '%@' - skipped!", [value class], value);
	}
}

-(void) injectPropertiesFromKeyPath:(const NSString* const)keyPath target:(id)target
{
	NSAssert(target != nil, @"target is nil!");
	
	NSDictionary* previousKeyPath = selectedDict;
	[self selectKeyPath:keyPath];
	
	for (NSString* key in selectedDict)
	{
		id value = [selectedDict valueForKey:key];
		if ([value isKindOfClass:[NSDictionary class]])
		{
			continue;
		}
		
		NSString* selectorName = [NSString stringWithFormat:@"set%@:", key];
		SEL propertySetter = NSSelectorFromString(selectorName);
		
		if ([target respondsToSelector:propertySetter])
		{
			NSMethodSignature* sig = [[target class] instanceMethodSignatureForSelector:propertySetter];
			NSAssert2(sig != nil, @"MethodSignature for object %@ and selector %@ is nil!", target, selectorName);
			
			if (sig != nil)
			{
				NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
				NSAssert(invocation != nil, @"invocation is nil!");
				
				//CCLOG(@"Setting property of %@ to %@%@ (%s)", target, selectorName, value, [sig getArgumentTypeAtIndex:2]);
				[invocation setTarget:target];
				[invocation setSelector:propertySetter];
				[self setInvocationArgument:invocation value:value signature:sig];
				[invocation invoke];
			}
		}
		else
		{
			CCLOG(@"===> WARNING: property setter '%@' not defined in target: %@ <===", selectorName, target);
		}
	}
	
	selectedDict = previousKeyPath;
}

+(void) injectPropertiesFromKeyPath:(NSString*)keyPath target:(id)target
{
	[[KKConfig sharedConfig] injectPropertiesFromKeyPath:keyPath target:target];
}

@end

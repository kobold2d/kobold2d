//
//  KoboldVersion.m
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KoboldVersion.h"
#import "XcodeProject.h"
#import "ProjectsDataSource.h"

@interface KoboldVersion (PrivateMethods)
-(void) initProjects;
@end

@implementation KoboldVersion

@synthesize projects;
@synthesize name, path, destinationPath, versionString;

-(id) initWithPath:(NSString*)aPath destinationPath:(NSString*)aDestinationPath
{
	if ((self = [super init]))
	{
		self.path = aPath;
		self.destinationPath = aDestinationPath;
		self.name = [aPath lastPathComponent];
		self.versionString = [name stringByReplacingOccurrencesOfString:@"Kobold2D-" withString:@""];
		[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Initialized Kobold2D version at '%@' with destination '%@', name '%@', versionString '%@'", 
						  path, destinationPath, name, versionString]];
		
		[self initProjects];
	}
	return self;
}

-(void) dealloc
{
	[projects release];
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"FileRef"])
	{
		NSString* location = [attributeDict valueForKey:@"location"];
		if (location)
		{
			//NSLog(@"location: %@", location);
			NSArray* components = [location componentsSeparatedByString:@":"];
			NSAssert([components count] == 2, @"location does not have the correct number of components, possible Xcode file format change ...");
			
			NSString* pathToXcodeProject = [components objectAtIndex:1];
			
			// skip internal projects
			if ([[pathToXcodeProject lowercaseString] hasPrefix:@"__kobold2d__/"])
			{
				return;
			}

			pathToXcodeProject = [NSString stringWithFormat:@"%@/%@", path, pathToXcodeProject];
			XcodeProject* project = [[[XcodeProject alloc] initWithWorkspacePath:currentWorkspacePath projectPath:pathToXcodeProject] autorelease];
			project.fileRefLocation = location;

			// skip existing projects
			NSString* destinationProjectPath = [NSString stringWithFormat:@"%@%@", destinationPath, project.pathRelativeToWorkspacePath];
			NSLog(@"destination project path: %@", destinationProjectPath);
			[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Project destination path after upgrade will be: %@", destinationProjectPath]];
			
			if ([[NSFileManager defaultManager] fileExistsAtPath:destinationProjectPath] == NO)
			{
				[projects addObject:project];
				NSLog(@"Added Project: %@", project.name);
			}
			else
			{
				[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"IGNORING project '%@' because destination path '%@' already exists!", project.name, destinationProjectPath]];
			}
		}
	}
}

- (void)parseWorkspaceContents:(NSString *)pathToFile
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:pathToFile])
	{
		NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathToFile]];
		[parser setDelegate:self];
		BOOL success = [parser parse];
		[parser release];

		if (success == NO)
		{
			NSLog(@"Parsing '%@' failed!", pathToFile);
			[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Parsing failed, malformed XML: %@", pathToFile]];
		}
	}
	else
	{
		NSLog(@"The workspace file '%@' does not exist!", pathToFile);
		[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Parsing failed, file does not exist: %@", pathToFile]];
	}
}

-(void) initProjects
{
	[projects release];
	projects = [[NSMutableArray alloc] initWithCapacity:10];
	
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	NSArray* contents = [fileManager contentsOfDirectoryAtPath:path error:nil];

	[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Trying to locate upgradeable projects in %@", path]];

	for (NSString* item in contents)
	{
		if ([item hasSuffix:@".xcworkspace"])
		{
			NSLog(@"Reading workspace: %@", item);
			[[ProjectsDataSource sharedDataSource] addLogLine:[NSString stringWithFormat:@"Found a workspace named %@, begin parsing contents ...", item]];
			currentWorkspacePath = [NSString stringWithFormat:@"%@/%@", path, item];
			
			NSString* workspaceContentsFile = [NSString stringWithFormat:@"%@/contents.xcworkspacedata", currentWorkspacePath];
			[self parseWorkspaceContents:workspaceContentsFile];
		}
	}
	
	[fileManager release];
	fileManager = nil;
	
	[projects sortUsingSelector:@selector(compareWith:)];
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ name: %@, path: %@, versionString: %@", [super description], name, path, versionString];
}

-(NSComparisonResult) compareWith:(id)object
{
	NSComparisonResult result = NSOrderedSame;
	
	if ([object isKindOfClass:[KoboldVersion class]])
	{
		KoboldVersion* other = (KoboldVersion*)object;
		result = [self.name compare:other.name];
		if (result == NSOrderedAscending) 
		{
			result = NSOrderedDescending;
		}
		else if (result == NSOrderedDescending)
		{
			result = NSOrderedAscending;
		}
	}
	
	return result;
}

@end

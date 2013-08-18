//
//  ProjectsDataSource.h
//  Kobold2D Project Upgrader
//
//  Created by Steffen Itterheim on 01.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KoboldVersion;

@interface ProjectsDataSource : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSComboBoxDelegate, NSComboBoxDataSource>
{
	NSMutableString* logOutput;
	NSMutableArray* versions;
	NSComboBox *previousVersions;
	NSTableView *previousVersionProjects;
	NSTextField *currentVersionLabel;
	NSButton *upgradeButton;
	NSProgressIndicator *progressIndicator;
	
	KoboldVersion* currentVersion;
	KoboldVersion* selectedVersion;
	
	BOOL debugging;
	NSString* koboldInstallDir;
	
	BOOL upgradeComplete;
	NSTextField *notesText;
	NSScrollView *tableView;
	NSTextField *noProjectsLabel;
}
@property (assign) IBOutlet NSTextField *noProjectsLabel;
@property (assign) IBOutlet NSScrollView *tableView;
@property (assign) IBOutlet NSTextField *notesText;
@property (assign) IBOutlet NSComboBox *previousVersions;
@property (assign) IBOutlet NSTableView *previousVersionProjects;
@property (assign) IBOutlet NSTextField *currentVersionLabel;
@property (assign) IBOutlet NSButton *upgradeButton;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
- (IBAction)upgradeClicked:(id)sender;
- (IBAction)helpClicked:(id)sender;

+(ProjectsDataSource*) sharedDataSource;
-(void) addLogLine:(NSString*)line;

@end

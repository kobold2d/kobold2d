/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>


@interface MainWindowController : NSWindowController <NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource>
{
@private
	NSMutableString* logOutput;
	NSMutableArray* templates;
	NSMutableArray* descriptions;
	NSMutableArray* workspaces;
    
	NSComboBox *workspaceList;
	NSTextField *pathToKobold2D;
	NSTableView *templatesList;
	NSTextField *createProjectName;
	NSButton *createProjectButton;
	NSTextField *templateDescription;
	NSButton *autoOpenProject;
	
	BOOL debugging;
}
@property (assign) IBOutlet NSComboBox *workspaceList;
@property (assign) IBOutlet NSTextField *pathToKobold2D;
@property (assign) IBOutlet NSTableView *templatesList;
@property (assign) IBOutlet NSTextField *createProjectName;
@property (assign) IBOutlet NSButton *createProjectButton;
@property (assign) IBOutlet NSTextField *templateDescription;
@property (assign) IBOutlet NSButton *autoOpenProject;
- (IBAction)createProject:(id)sender;

-(void) tryFindPathToKobold2D;
- (IBAction)helpClicked:(id)sender;

@end

/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface CBHomeViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTableView *projectsTableView;
@property (strong) IBOutlet NSArrayController *projectsArrayController;
@property (strong) NSArray * projectsArrayControllerSortDescriptors;

- (IBAction)openStoryButton:(id)sender;

@end

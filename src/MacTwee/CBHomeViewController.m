/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBHomeViewController.h"
#import "CBProjectEditor.h"

@implementation CBHomeViewController

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib {
	self.projectsArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:NO] ];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////

- (IBAction)openStoryButton:(id)sender {
	//NSLog(@"%s 'Line:%d' - sender:'%@'", __func__, __LINE__, sender);
	if ( (long)self.projectsArrayController.selectionIndex > -1 ) {
		if ( self.projectsArrayController.selectedObjects.count > 0 ) {
			[CBProjectEditor sharedCBProjectEditor].currentProject = [[self.projectsArrayController selectedObjects] objectAtIndex:0];
			NSDictionary* dict = @{ @"index" : [NSNumber numberWithLong:CBPageProject] };
			[[NSNotificationCenter defaultCenter] postNotificationName:kCBPrimaryWindowControllerWillOpenViewNotification
																object:self
															  userInfo:dict];
		}
	} else {
		NSLog(@"Nothing selected");
	}
}

- (IBAction)doubleClickTableItem:(id)sender {
	[self openStoryButton:self];
}

@end

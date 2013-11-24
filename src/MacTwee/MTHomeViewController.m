//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTHomeViewController.h"
#import "MTProjectEditor.h"


@implementation MTHomeViewController

#pragma mark - Lifecycle

- (void)awakeFromNib {
	self.projectsArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:NO] ];
}


#pragma mark - Public

- (IBAction)openStoryButton:(id)sender {
	//NSLog(@"%s 'Line:%d' - sender:'%@'", __func__, __LINE__, sender);
	if ( (long)self.projectsArrayController.selectionIndex > -1 ) {
		if ( self.projectsArrayController.selectedObjects.count > 0 ) {
			[[MTProjectEditor sharedMTProjectEditor] setupCurrentProject:[self.projectsArrayController selectedObjects][0] ];
			NSDictionary * dict = @{ @"index" : [NSNumber numberWithLong:MTPageProject] };
			[[NSNotificationCenter defaultCenter] postNotificationName:MTPrimaryWindowControllerWillOpenViewNotification
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

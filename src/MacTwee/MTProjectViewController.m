/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "MTProjectViewController.h"
#import "MTCoreDataManager.h"
#import "MTProjectEditor.h"
#import "MTProject.h"

@implementation MTProjectViewController

- (void)awakeFromNib {
	//self.passageTextView.backgroundColor = [NSColor blackColor];
	//self.passageTextView.insertionPointColor = [NSColor whiteColor];
	//self.passageTextView.textColor = [NSColor whiteColor];
	self.passageTextView.font = [NSFont userFontOfSize:16];
	self.passagesArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(processNotification:)
												 name:mtTextViewControllerDidGetPotentialPassageClickNotification
											   object:nil];
}

#pragma mark - Private
- (void)processNotification:(NSNotification *)notification {
	//NSLog(@"%s:%d:Notification is successfully received! notification.name '%@'", __func__, __LINE__, notification.name);
	
    if ([notification.name isEqualToString:mtTextViewControllerDidGetPotentialPassageClickNotification]) {
		if ( [notification userInfo][@"index"] ) {
			NSString * passageName = [notification userInfo][@"index"];
			//NSLog(@"%s 'Line:%d' - The object for key index is:'%@'", __func__, __LINE__, passageName);
			[[MTProjectEditor sharedMTProjectEditor] selectCurrentPassageWithName:passageName];
		}
	}
}
- (IBAction)passagesTableClick:(id)sender {
	if (![sender respondsToSelector:@selector(selectedRow)]) {
		return;
	}
	NSUInteger selectedRow = [sender selectedRow];
	//NSLog(@"%s 'Line:%d' - selectedRow:%ld", __func__, __LINE__, selectedRow);
	if ( selectedRow != -1 ) {
		if ([[self.passageArrayController selectedObjects] count] > 0) {
			id selectedPassage = self.passageArrayController.selectedObjects[0];
			if (selectedPassage != nil) {
				//NSLog(@"%s 'Line:%d' - selection description:'%@'", __func__, __LINE__, selectedPassage);
				[[MTProjectEditor sharedMTProjectEditor] setCurrentPassage:selectedPassage];
			}
		}
	}
}
@end

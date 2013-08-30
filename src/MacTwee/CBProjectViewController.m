/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBProjectViewController.h"
#import "CBCoreDataManager.h"
#import "CBProjectEditor.h"
#import "CBProject.h"

@implementation CBProjectViewController

- (void)awakeFromNib {
	//self.passageTextView.backgroundColor = [NSColor blackColor];
	//self.passageTextView.insertionPointColor = [NSColor whiteColor];
	//self.passageTextView.textColor = [NSColor whiteColor];
	self.passageTextView.font = [NSFont userFontOfSize:16];
	self.passagesArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(processNotification:)
												 name:kCBTextViewControllerDidGetPotentialPassageClickNotification
											   object:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (void)processNotification:(NSNotification *)notification {
	//NSLog(@"%s:%d:Notification is successfully received! notification.name '%@'", __func__, __LINE__, notification.name);
	
    if ([notification.name isEqualToString:kCBTextViewControllerDidGetPotentialPassageClickNotification]) {
		if ( [[notification userInfo] objectForKey:@"index"] ) {
			NSString * passageName = [[notification userInfo] objectForKey:@"index"];
			//NSLog(@"%s 'Line:%d' - The object for key index is:'%@'", __func__, __LINE__, passageName);
			[[CBProjectEditor sharedCBProjectEditor] selectCurrentPassageWithName:passageName];
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
				[[CBProjectEditor sharedCBProjectEditor] setCurrentPassage:selectedPassage];
			}
		}
	}
}
@end

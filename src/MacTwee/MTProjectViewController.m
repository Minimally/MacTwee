
#import "MTProjectViewController.h"
#import "MTCoreDataManager.h"
#import "MTProjectEditor.h"
#import "MTProject.h"


@implementation MTProjectViewController


#pragma mark - Lifecycle

- (void)awakeFromNib {
	//self.passageTextView.backgroundColor = [NSColor blackColor];
	//self.passageTextView.insertionPointColor = [NSColor whiteColor];
	//self.passageTextView.textColor = [NSColor whiteColor];
	self.passageTextView.font = [NSFont userFontOfSize:16];
	self.passagesArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] ];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(processNotification:)
												 name:MTTextViewControllerDidGetPotentialPassageClickNotification
											   object:nil];
}


#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[self updateSelectedPassage];
}


#pragma mark - Private

- (void)updateSelectedPassage {
    if ( self.passageArrayController.selectedObjects.count >= 1 ) {
        id selectedPassage = self.passageArrayController.selectedObjects[0];
        if (selectedPassage != nil) {
            [[MTProjectEditor sharedMTProjectEditor] setCurrentPassage:selectedPassage];
        }
    }
    else {
        [[MTProjectEditor sharedMTProjectEditor] setCurrentPassage:nil];
    }
}

- (void)processNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:MTTextViewControllerDidGetPotentialPassageClickNotification]) {
        // the user alt clicked a link within the text view, we need to try and go to it
		if ( [notification userInfo][@"index"] ) {
			NSString * passageName = [notification userInfo][@"index"];
			//NSLog(@"%s 'Line:%d' - The object for key index is:'%@'", __func__, __LINE__, passageName);
			if ( [[MTProjectEditor sharedMTProjectEditor] selectCurrentPassageWithName:passageName] ) {
                if ([MTProjectEditor sharedMTProjectEditor].currentPassage != nil) {
                    [self.passageArrayController setSelectedObjects:@[[MTProjectEditor sharedMTProjectEditor].currentPassage]];
                }
            }
		}
	}
}


@end

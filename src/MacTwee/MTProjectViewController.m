//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTProjectViewController.h"
#import "MTCoreDataManager.h"
#import "MTProjectEditor.h"
#import "MTProject.h"
#import "MTVisualEditorScene.h"


@implementation MTProjectViewController


#pragma mark - Lifecycle

- (void)awakeFromNib {
	//self.passageTextView.backgroundColor = [NSColor blackColor];
	//self.passageTextView.insertionPointColor = [NSColor whiteColor];
	//self.passageTextView.textColor = [NSColor whiteColor];
	self.passageTextView.font = [NSFont userFontOfSize:16];
	self.passagesArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] ];
    
    NSAssert(self.visualEditorSKView != nil, @"self.visualEditorSKView is nil");
    [self.visualEditorSKView addTrackingRect:self.visualEditorSKView.bounds owner:self.visualEditorSKView userData:nil assumeInside:NO]; // hack for mouse events
	SKScene * scene = [MTVisualEditorScene sceneWithSize:CGSizeMake(1024, 768)];
    self.visualEditorSKView.showsFPS = YES;
    self.visualEditorSKView.showsNodeCount = YES;
    self.visualEditorSKView.showsDrawCount = YES;
    [self.visualEditorSKView presentScene:scene];
    
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

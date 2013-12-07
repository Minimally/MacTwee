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
#import "MTPassage.h"
#import "MTVisualEditorScene.h"


@implementation MTProjectViewController


#pragma mark - Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    NSAssert(self.passageArrayController != nil, @"self.passageArrayController is nil");
    self.passageArrayController.selectsInsertedObjects = YES;
	self.passagesArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)] ];
    
    NSAssert(self.visualEditorSKView != nil, @"self.visualEditorSKView is nil");
    [self.visualEditorSKView addTrackingRect:self.visualEditorSKView.bounds owner:self.visualEditorSKView userData:nil assumeInside:NO]; // hack for mouse events
	SKScene * scene = [MTVisualEditorScene sceneWithSize:CGSizeMake(1024, 768)];
    self.visualEditorSKView.showsFPS = self.visualEditorSKView.showsNodeCount = self.visualEditorSKView.showsDrawCount = [[NSUserDefaults standardUserDefaults] boolForKey:kVisualDisplayDebug];
    [self.visualEditorSKView presentScene:scene];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:MTTweeImporUtilityDidImportFile
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:MTAppDelegateDidGetMenuClickNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:MTTextViewControllerDidGetPotentialPassageClickNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:MTTweeFileToolsDidGetBuiltFile
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewProgressFinish)
                                                 name:WebViewProgressFinishedNotification
                                               object:self.webView];
}


#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	[self updateSelectedPassage];
}


#pragma mark - IBAction

- (IBAction)deletePassage:(id)sender {
    for (MTPassage * passage in self.passageArrayController.selectedObjects) {
        [[MTCoreDataManager sharedMTCoreDataManager].managedObjectContext deleteObject:passage];
    }
    [MTProjectEditor sharedMTProjectEditor].currentPassage = nil;
}

- (IBAction)webViewNavigate:(id)sender {
    if ([sender respondsToSelector:@selector(tag)]) {
        long tag = [sender tag];
        if (tag == 0) { // back
            [self.webView goBack];
        }
        else if (tag == 1) { // forward
            [self.webView goForward];
        }
    }
}


#pragma mark - Private

/// updates the currently selected passage in MTProjectEditor

- (void)updateSelectedPassage {
    if ( self.passageArrayController.selectedObjects.count == 1 ) {
        id selectedPassage = self.passageArrayController.selectedObjects[0];
        if (selectedPassage != nil) {
            [[MTProjectEditor sharedMTProjectEditor] setCurrentPassage:selectedPassage];
        }
    }
    else {
        [[MTProjectEditor sharedMTProjectEditor] setCurrentPassage:nil];
    }
}

/// called after notifcations recieved

- (void)processNotification:(NSNotification *)notification {
    
    if ( [notification.name isEqualToString:MTTweeImporUtilityDidImportFile] ) {
        MTVisualEditorScene * scene = (MTVisualEditorScene *)self.visualEditorSKView.scene;
        [[MTProjectEditor sharedMTProjectEditor] updateCurrentProject];
        scene.needsUpdate = YES;
    }
    else if ( [notification.name isEqualToString:MTTextViewControllerDidGetPotentialPassageClickNotification] ) {
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
    
    else if ( [notification.name isEqualToString:MTAppDelegateDidGetMenuClickNotification] ) {
        NSNumber * index = [notification userInfo][@"index"];
        if ( [index integerValue] == MTMenuBtnNew ) {
            [[MTProjectEditor sharedMTProjectEditor] newPassage];
            //MTPassage * passage = [MTPassage passage];
            //passage.project = [MTProjectEditor sharedMTProjectEditor].currentProject;
            //[self.passageArrayController setSelectedObjects:@[passage]];
            //[self updateSelectedPassage];
        }
    }
    
    else if ( [notification.name isEqualToString:MTTweeFileToolsDidGetBuiltFile] ) {
        NSString * index = [notification userInfo][@"index"];
        NSURL * url = [NSURL fileURLWithPath:index];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView.mainFrame loadRequest:request];
        //self.webViewAddressBar.stringValue = url.path;
    }
}

/// called after WebViewProgressFinishedNotification on self.webview

- (void)webViewProgressFinish { NSLog(@"%d | %s - comment", __LINE__, __func__); }


@end

//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTHomeViewController.h"
#import "MTProjectEditor.h"
#import "MTProject.h"


@implementation MTHomeViewController

#pragma mark - Lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
	self.projectsArrayControllerSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"lastModifiedDate" ascending:NO] ];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processNotification:)
                                                 name:MTAppDelegateDidGetMenuClickNotification
                                               object:nil];
}

#pragma mark - IBAction

- (IBAction)openStoryButton:(id)sender {
	if ( self.projectsArrayController.selectedObjects.count > 0 ) {
        [self openProject:self.projectsArrayController.selectedObjects[0]];
    }
}

- (IBAction)newStoryButton:(id)sender {
    [self openProject:[MTProject project]];
}

- (IBAction)deleteStoryButton:(id)sender {
    if ( self.projectsArrayController.selectedObjects.count > 0 ) {
        [self.projectsArrayController removeObject:self.projectsArrayController.selectedObjects[0]];
    }
}

- (IBAction)doubleClickTableItem:(id)sender {
	[self openStoryButton:self];
}


#pragma mark - Private

- (void)processNotification:(NSNotification *)notification {
    if ( [notification.name isEqualToString:MTAppDelegateDidGetMenuClickNotification] ) {
        NSNumber * index = [notification userInfo][@"index"];
        if ( [index integerValue] == MTMenuBtnNew ) {
            [self openProject:[MTProject project]];
        }
    }
}

- (void)openProject:(MTProject *)project {
    [[MTProjectEditor sharedMTProjectEditor] setupCurrentProject:project];
    NSDictionary * dict = @{ @"index" : [NSNumber numberWithLong:MTPageProject] };
    [[NSNotificationCenter defaultCenter] postNotificationName:MTPrimaryWindowControllerWillOpenViewNotification
                                                        object:self
                                                      userInfo:dict];
}


@end

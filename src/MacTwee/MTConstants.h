//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>


@interface MTConstants : NSObject

typedef enum {
    MTPageHome = 0,
    MTPageProject,
} MTPage;

typedef enum {
    MTMenuBtnNew = 0,
    MTMenuBtnHome,
} MTMenuBtn;

#pragma mark - notifications

extern NSString * const MTPrimaryWindowControllerWillOpenViewNotification;

/// triggered when user alt clicks a link in the text view
extern NSString * const MTTextViewControllerDidGetPotentialPassageClickNotification;

/// various menu items selected by user
extern NSString * const MTAppDelegateDidGetMenuClickNotification;
extern NSString * const MTTweeImporUtilityDidImportFile;

#pragma mark - paths

extern NSString * const kOpenPath;
extern NSString * const kSavePath;
extern NSString * const kPathToTwee;

#pragma mark - assorted strings

extern NSString * const kdefaultBuildName;
extern NSString * const kdefaultSourceName;
extern NSString * const kUserApplicationSupportDirectory;
extern NSString * const kLinkMatch;

@end

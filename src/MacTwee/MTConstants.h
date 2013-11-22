/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface MTConstants : NSObject

typedef enum {
    MTPageHome = 0,
    MTPageProject
} MTPage;

// notifications
extern NSString * const MTPrimaryWindowControllerWillOpenViewNotification;
extern NSString * const mtTextViewControllerDidGetPotentialPassageClickNotification;

// paths
extern NSString * const kOpenPath;
extern NSString * const kSavePath;
extern NSString * const kPathToTwee;

// assorted strings
extern NSString * const kdefaultBuildName;
extern NSString * const kdefaultSourceName;
extern NSString * const kUserApplicationSupportDirectory;
extern NSString * const kLinkMatch;

@end

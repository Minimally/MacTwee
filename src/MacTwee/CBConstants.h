/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface CBConstants : NSObject

typedef enum {
    CBPageHome = 0,
    CBPageProject
} CBPage;

// notifications
extern NSString * const kCBPrimaryWindowControllerWillOpenViewNotification;

// paths
extern NSString * const kOpenPath;
extern NSString * const kSavePath;
extern NSString * const kPathToTwee;
extern NSString * const kLastBuildName;
extern NSString * const kLastSourceName;
extern NSString * const kLastBuildDirectory;

// assorted strings
extern NSString * const kdefaultBuildName;
extern NSString * const kdefaultSourceName;
extern NSString * const kUserApplicationSupportDirectory;
@end

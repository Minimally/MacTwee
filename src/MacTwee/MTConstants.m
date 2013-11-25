//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTConstants.h"


@implementation MTConstants


#pragma mark - notifications

NSString * const MTPrimaryWindowControllerWillOpenViewNotification = @"MTPrimaryWindowControllerWillOpenViewNotification";
NSString * const MTTextViewControllerDidGetPotentialPassageClickNotification = @"altClickLink";
NSString * const MTAppDelegateDidGetMenuClickNotification = @"menuButtonClick";


#pragma mark - paths

NSString * const kOpenPath = @"kOpenPath";
NSString * const kSavePath = @"kSavePath";
NSString * const kPathToTwee = @"kPathToTwee";


#pragma mark - assorted strings

NSString * const kdefaultBuildName = @"build.html";
NSString * const kdefaultSourceName = @"source.twee";
NSString * const kUserApplicationSupportDirectory = @"MacTwee";
NSString * const kLinkMatch = @"kLinkMatch";


@end

//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTConstants.h"


@implementation MTConstants


#pragma mark - notifications

NSString * const MTTweeBuildUtilityDidGetProjectBuildDestination = @"buildDestinationSet";
NSString * const MTPrimaryWindowControllerWillOpenViewNotification = @"MTPrimaryWindowControllerWillOpenViewNotification";
NSString * const MTTextViewControllerDidGetPotentialPassageClickNotification = @"altClickLink";
NSString * const MTAppDelegateDidGetMenuClickNotification = @"menuButtonClick";
NSString * const MTTweeImporUtilityDidImportFile = @"didImportTweeFile";
NSString * const MTTweeFileToolsDidGetBuiltFile = @"buildFileHappened";

#pragma mark - paths

NSString * const kOpenPath = @"kOpenPath";
NSString * const kSavePath = @"kSavePath";


#pragma mark - assorted strings

NSString * const kdefaultBuildName = @"build.html";
NSString * const kdefaultSourceName = @"source.twee";
NSString * const kUserApplicationSupportDirectory = @"MacTwee";
NSString * const kLinkMatch = @"kLinkMatch";

#pragma mark - Preference Keys

NSString * const kPathToTwee = @"kPathToTwee";
NSString * const kRunInWebView = @"useInternalWebView";
NSString * const kTextSize = @"textSize";
NSString * const kExitOnLastClose = @"exitOnLastClose";
NSString * const kVisualUseCurves = @"visualUseCurves";
NSString * const kVisualDisplayDebug = @"visualDisplayDebug";


@end

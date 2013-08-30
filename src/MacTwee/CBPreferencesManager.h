/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface CBPreferencesManager : NSObject

+ (NSURL *)tweeDirectory;

+ (NSString *)lastBuildName;
+ (void)setLastBuildName:(NSString *)buildName;

+ (NSString *)lastSourceName;
+ (void)setLastSourceName:(NSString *)sourceName;

+ (NSURL *)lastBuildDirectory;
+ (void)setLastBuildDirectory:(NSURL *)directory;

+ (void)checkDefaults;
@end
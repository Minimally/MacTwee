//
//  NSUserDefaults+ColorSupport.h
//  MacTwee
//
//  Created by CGB on 8/30/13.
//  Copyright (c) 2013 Chris Braithwaite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (ColorSupport)
- (void)setColorZ:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKeyZ:(NSString *)aKey;
@end

//
//  NSUserDefaults+ColorSupport.m
//  MacTwee
//
//  Created by CGB on 8/30/13.
//  Copyright (c) 2013 Chris Braithwaite. All rights reserved.
//

#import "NSUserDefaults+ColorSupport.h"

@implementation NSUserDefaults (ColorSupport)
- (void)setColorZ:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}
- (NSColor *)colorForKeyZ:(NSString *)aKey
{
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}
@end

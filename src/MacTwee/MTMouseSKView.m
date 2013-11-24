//
//  MTCustomSKView.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/24/13.
//  Copyright (c) 2013 MacTwee. All rights reserved.
//

#import "MTMouseSKView.h"

@implementation MTMouseSKView

//
// The mouseEntered: and mouseExited: will turn on and off our mouse tracking.
//

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.window.acceptsMouseMovedEvents = YES;
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.window.acceptsMouseMovedEvents = NO;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if ([self.scene respondsToSelector:@selector(scrollWheel:)]) {
        [self.scene performSelector:@selector(scrollWheel:) withObject:theEvent];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if ([self.scene respondsToSelector:@selector(rightMouseDown:)]) {
        [self.scene performSelector:@selector(rightMouseDown:) withObject:theEvent];
    }
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    if ([self.scene respondsToSelector:@selector(otherMouseDragged:)]) {
        [self.scene performSelector:@selector(otherMouseDragged:) withObject:theEvent];
    }
}

@end

/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTextView.h"

@implementation CBTextView

BOOL holdingAlt = NO;

- (void)mouseDown:(NSEvent *)theEvent {
	NSAssert(theEvent != nil, @"theEvent is nil");
	[super mouseDown:theEvent];
	
	if (!holdingAlt)
		return;
	
    // identify the coordinates of the mouse event, then translate that into the part of the string that falls underneath the mouse cursor
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSInteger charIndex = [self characterIndexForInsertionAtPoint:point]; // retrieve the character position for a given coordinate,
	
	charIndex = (charIndex >= self.attributedString.length) ? self.attributedString.length - 1 : charIndex;
	
	NSAttributedString * aString = self.attributedString;
		
	NSDictionary * attributes = [aString attributesAtIndex:charIndex effectiveRange:NULL]; // retrieve the attributes for that specific position
	
	NSString * result = [attributes objectForKey:kLinkMatch];
	
	if( result != nil ) {
		//NSLog(@"%s 'Line:%d' - LinkMatch: '%@'", __func__, __LINE__, result);
		[self.delegate linkMatchMade:self matchedString:result];
	}
}

- (void)flagsChanged:(NSEvent *)theEvent {
	NSUInteger mod = theEvent.modifierFlags;
	//NSLog(@"%s 'Line:%d' - mod flags:'%lu' NSAlternateKeyMask is '%u'", __func__, __LINE__, mod, NSAlternateKeyMask);
	holdingAlt = (mod & NSAlternateKeyMask) ? YES : NO;
}

@end

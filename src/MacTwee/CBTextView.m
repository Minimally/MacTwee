/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTextView.h"

@implementation CBTextView

- (void)mouseDown:(NSEvent *)theEvent {
    // identify the coordinates of the mouse event, then translate that into the part of the string that falls underneath the mouse cursor
	
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSInteger charIndex = [self characterIndexForInsertionAtPoint:point]; // retrieve the character position for a given coordinate,
		
	charIndex = ((charIndex < 0) ? 0 : (charIndex > self.attributedString.length) ? self.attributedString.length : charIndex);
	
	NSDictionary * attributes = [[self attributedString] attributesAtIndex:charIndex effectiveRange:NULL]; // retrieve the attributes for that specific position
	
	if( [attributes objectForKey:kLinkMatch] != nil ) {
		NSString * result = [attributes objectForKey:kLinkMatch];
		//NSLog(@"%s 'Line:%d' - LinkMatch: '%@'", __func__, __LINE__, result);
		[self.delegate linkMatchMade:self matchedString:result];
	}
    
	[super mouseDown:theEvent];
}

@end

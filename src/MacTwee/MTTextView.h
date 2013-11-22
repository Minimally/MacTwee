/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Cocoa/Cocoa.h>


@class MTTextView;
@protocol MTTextViewDelegate
- (void)linkMatchMade:(MTTextView *)sender matchedString:(NSString *)matchedString;
@end

@interface MTTextView : NSTextView
@property (weak, nonatomic) id <MTTextViewDelegate> delegate; //define MyClassDelegate as delegate
@end

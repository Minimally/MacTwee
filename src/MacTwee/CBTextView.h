/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Cocoa/Cocoa.h>


@class CBTextView;
@protocol CBTextViewDelegate
- (void)linkMatchMade:(CBTextView *)sender matchedString:(NSString *)matchedString;
@end

@interface CBTextView : NSTextView
@property (weak, nonatomic) id <CBTextViewDelegate> delegate; //define MyClassDelegate as delegate
@end

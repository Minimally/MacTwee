//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Cocoa/Cocoa.h>
@class MTTextView;


/*! protocol for sending an alt clicks text */

@protocol MTTextViewDelegate

- (void)linkMatchMade:(MTTextView *)sender matchedString:(NSString *)matchedString;

@end


/*! Custom view that captures alt clicks */

@interface MTTextView : NSTextView

@property (weak, nonatomic) id <MTTextViewDelegate> delegate; //define MyClassDelegate as delegate

@end

/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "MTTextView.h"

@interface MTTextViewController : NSObject <NSTextStorageDelegate, MTTextViewDelegate>

@property (unsafe_unretained) IBOutlet MTTextView *passageTextView;

@end

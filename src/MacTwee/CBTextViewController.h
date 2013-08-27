/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "CBTextView.h"

@interface CBTextViewController : NSObject <NSTextStorageDelegate, CBTextViewDelegate>

@property (unsafe_unretained) IBOutlet CBTextView *passageTextView;

@end

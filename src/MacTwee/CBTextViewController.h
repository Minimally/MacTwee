/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface CBTextViewController : NSObject <NSTextStorageDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *passageTextView;

@end

/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface CBProjectViewController : NSViewController
@property (unsafe_unretained) IBOutlet NSTextView *passageTextView;
@property (strong) NSArray * passagesArrayControllerSortDescriptors;
@end

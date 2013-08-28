/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface CBProjectViewController : NSViewController

@property (strong) IBOutlet NSArrayController *passageArrayController;
@property (unsafe_unretained) IBOutlet NSTextView *passageTextView;
@property (strong) NSArray * passagesArrayControllerSortDescriptors;


- (IBAction)passagesTableClick:(id)sender;

@end

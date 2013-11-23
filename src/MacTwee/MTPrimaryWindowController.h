//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Cocoa/Cocoa.h>


@interface MTPrimaryWindowController : NSWindowController

@property (strong, readonly) NSViewController * currentViewController;
@property (unsafe_unretained) IBOutlet NSView * holderView;


-(void)selectView:(NSInteger)whichViewTag;

- (IBAction)newPassage:(id)sender;

- (IBAction)buildStory:(id)sender;
- (IBAction)buildAndRun:(id)sender;

- (IBAction)importStory:(id)sender;
- (IBAction)exportStory:(id)sender;

@end

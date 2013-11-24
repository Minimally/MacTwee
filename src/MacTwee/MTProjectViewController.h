//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SpriteKit.h>


@interface MTProjectViewController : NSViewController <NSTableViewDelegate>

@property (strong) IBOutlet NSArrayController * passageArrayController;
@property (unsafe_unretained) IBOutlet NSTextView * passageTextView;
@property (strong) NSArray * passagesArrayControllerSortDescriptors;
@property (weak) IBOutlet SKView * visualEditorSKView;

@end

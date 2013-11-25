//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Cocoa/Cocoa.h>


@interface MTHomeViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTableView * projectsTableView;
@property (strong) IBOutlet NSArrayController * projectsArrayController;
@property (strong) NSArray * projectsArrayControllerSortDescriptors;

- (IBAction)openStoryButton:(id)sender;
- (IBAction)newStoryButton:(id)sender;
- (IBAction)deleteStoryButton:(id)sender;

@end


#import <Cocoa/Cocoa.h>


@interface MTHomeViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTableView * projectsTableView;
@property (strong) IBOutlet NSArrayController * projectsArrayController;
@property (strong) NSArray * projectsArrayControllerSortDescriptors;

- (IBAction)openStoryButton:(id)sender;

@end

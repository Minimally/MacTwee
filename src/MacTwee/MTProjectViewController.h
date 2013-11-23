
#import <Cocoa/Cocoa.h>


@interface MTProjectViewController : NSViewController

@property (strong) IBOutlet NSArrayController * passageArrayController;
@property (unsafe_unretained) IBOutlet NSTextView * passageTextView;
@property (strong) NSArray * passagesArrayControllerSortDescriptors;

- (IBAction)passagesTableClick:(id)sender;

@end

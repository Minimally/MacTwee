
#import <Cocoa/Cocoa.h>


@interface MTProjectViewController : NSViewController <NSTableViewDelegate>

@property (strong) IBOutlet NSArrayController * passageArrayController;
@property (unsafe_unretained) IBOutlet NSTextView * passageTextView;
@property (strong) NSArray * passagesArrayControllerSortDescriptors;

@end

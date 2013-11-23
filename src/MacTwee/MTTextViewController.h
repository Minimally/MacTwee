
#import <Foundation/Foundation.h>
#import "MTTextView.h"


/*! Controls the main passage editor text view. Does syntax highlights */

@interface MTTextViewController : NSObject <NSTextStorageDelegate, MTTextViewDelegate>

@property (unsafe_unretained) IBOutlet MTTextView *passageTextView;

@end

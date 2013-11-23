//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <Foundation/Foundation.h>
#import "MTTextView.h"


/*! Controls the main passage editor text view. Does syntax highlights */

@interface MTTextViewController : NSObject <NSTextStorageDelegate, MTTextViewDelegate>

@property (unsafe_unretained) IBOutlet MTTextView *passageTextView;

@end

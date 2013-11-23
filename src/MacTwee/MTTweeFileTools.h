
#import <Foundation/Foundation.h>


/*! Does Twee operations */

@interface MTTweeFileTools : NSObject

- (void)importTweeFile;
- (NSURL *)exportTweeFile;

- (void)buildStory;
- (void)buildAndRunStory;

@end

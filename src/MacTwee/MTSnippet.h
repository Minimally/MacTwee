
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MTSnippet : NSManagedObject

@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;

@end

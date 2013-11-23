
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class MTPassage;


@interface MTProject : NSManagedObject

@property (nonatomic, retain) NSString * buildDirectory;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * projectName;
@property (nonatomic, retain) NSString * sourceDirectory;
@property (nonatomic, retain) NSString * storyAuthor;
@property (nonatomic, retain) NSString * storyFormat;
@property (nonatomic, retain) NSString * storyTitle;
@property (nonatomic, retain) NSString * buildName;
@property (nonatomic, retain) NSString * sourceName;
@property (nonatomic, retain) NSSet * passages;
@end


@interface MTProject (CoreDataGeneratedAccessors)

- (void)addPassagesObject:(MTPassage *)value;
- (void)removePassagesObject:(MTPassage *)value;
- (void)addPassages:(NSSet *)values;
- (void)removePassages:(NSSet *)values;

@end

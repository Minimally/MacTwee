//
//  MTPassage.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/24/13.
//  Copyright (c) 2013 MacTwee. All rights reserved.
//

#import "MTPassage.h"
#import "MTPassage.h"
#import "MTProject.h"
#import "MTCoreDataManager.h"


@implementation MTPassage

@dynamic buildable;
@dynamic lastModifiedDate;
@dynamic locked;
@dynamic tags;
@dynamic text;
@dynamic title;
@dynamic xPosition;
@dynamic yPosition;
@dynamic incoming;
@dynamic outgoing;
@dynamic project;


- (void)populateLinks {
    
    NSRegularExpression * regExpression = [NSRegularExpression regularExpressionWithPattern:@"\\[\\[([^\\|\\]]*?)(?:(\\]\\])|(\\|(.*?)\\]\\]))" options:0 error:nil];
    
    [regExpression enumerateMatchesInString:self.text
									options:0
									  range:NSMakeRange(0, self.text.length)
								 usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
                                     
                                     NSRange substringRange = result.range;
                                     
                                     
                                     NSString * substring = [self.text substringWithRange:substringRange];
                                     //NSLog(@"%s 'Line:%d' - substring:'%@'", __func__, __LINE__, substring);
                                     
                                     // perform a search by passage name from the substring
                                     NSMutableString * searchString = [NSMutableString stringWithString:substring];
                                     [searchString deleteCharactersInRange:NSMakeRange(0, 2)];
                                     [searchString deleteCharactersInRange:NSMakeRange(searchString.length - 2, 2)];
                                     
                                     NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (project == %@)", searchString, self.project];
                                     NSArray * searchResult = [[MTCoreDataManager sharedMTCoreDataManager] executeFetchWithPredicate:predicate entity:@"Passage"];
                                     
                                     if (searchResult.count == 1) { // we have a link
                                         [self addOutgoingObject:searchResult[0]];
                                     }
                                     else { // we have a broken link
                                         
                                     }
                                 }];
}

@end

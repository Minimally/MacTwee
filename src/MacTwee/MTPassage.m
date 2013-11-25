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
#import "NSString+PDRegex.h"


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
    NSString * linkPattern = @"\\[\\[([^\\|\\]]*?)(?:(\\]\\])|(\\|(.*?)\\]\\]))";
    NSRegularExpression * regExpression = [NSRegularExpression regularExpressionWithPattern:linkPattern options:0 error:nil];
    [regExpression enumerateMatchesInString:self.text
									options:0
									  range:NSMakeRange(0, self.text.length)
								 usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
                                     
                                     NSRange substringRange = result.range;
                                     NSString * substring = [self.text substringWithRange:substringRange];
                                     //NSLog(@"%s 'Line:%d' - substring:'%@'", __func__, __LINE__, substring);
                                     
                                     // we have to extract title text from the substring, this is different for links vs display
                                     NSString * titleInSubstring = [NSString string];
                                     
                                     NSMutableString * ms = [NSMutableString stringWithString:substring];
                                     [ms deleteCharactersInRange:NSMakeRange(0, 2)];
                                     [ms deleteCharactersInRange:NSMakeRange(ms.length - 2, 2)];
                                     NSArray * pipeClear = [ms componentsSeparatedByString:@"|"];
                                     if (pipeClear.count == 1) {
                                         titleInSubstring = pipeClear[0];
                                     }
                                     else if (pipeClear.count == 2) {
                                         titleInSubstring = pipeClear[1];
                                     }
                                     else {
                                         NSLog(@"%d | %s - issue with pipeline in link", __LINE__, __func__);
                                     }
                                     
                                     titleInSubstring = ms;
                                     //NSLog(@"%s 'Line:%d' - titleInSubstring:'%@'", __func__, __LINE__, titleInSubstring);
                                     
                                     // perform a search by passage name from the titleInSubstring
                                     NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (project == %@)", titleInSubstring, self.project];
                                     NSArray * searchResult = [[MTCoreDataManager sharedMTCoreDataManager] executeFetchWithPredicate:predicate entity:@"Passage"];
                                     
                                     if (searchResult.count == 1) { // we have a link
                                         [self addOutgoingObject:searchResult[0]];
                                     }
                                     else { // we have a broken link
                                         
                                     }
                                 }];
    
    NSString * displayPattern = @"\\<\\<display\\s+[\'\"](.+?)[\'\"]\\s?\\>\\>";
    NSRegularExpression * displayRegExpression = [NSRegularExpression regularExpressionWithPattern:displayPattern options:0 error:nil];
    [displayRegExpression enumerateMatchesInString:self.text
									options:0
									  range:NSMakeRange(0, self.text.length)
								 usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
                                     
                                     NSRange substringRange = result.range;
                                     NSString * substring = [self.text substringWithRange:substringRange];
                                     //NSLog(@"%s 'Line:%d' - substring:'%@'", __func__, __LINE__, substring);
                                     
                                     // we have to extract title text from the substring, this is different for links vs display
                                     NSString * titleInSubstring = [NSString string];
                                     
                                     NSArray * a = [substring stringsByExtractingGroupsUsingRegexPattern:displayPattern caseInsensitive:YES treatAsOneLine:YES];
                                     if (a.count > 0) {
                                         titleInSubstring = a[0];
                                     }
                                     
                                     //NSLog(@"%s 'Line:%d' - titleInSubstring:'%@'", __func__, __LINE__, titleInSubstring);
                                     
                                     // perform a search by passage name from the titleInSubstring
                                     NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (project == %@)", titleInSubstring, self.project];
                                     NSArray * searchResult = [[MTCoreDataManager sharedMTCoreDataManager] executeFetchWithPredicate:predicate entity:@"Passage"];
                                     
                                     if (searchResult.count == 1) { // we have a link
                                         [self addOutgoingObject:searchResult[0]];
                                     }
                                     else { // we have a broken link
                                         
                                     }
                                 }];
}

@end

//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTTextViewController.h"
#import "NSString+PDRegex.h"
#import "MTCoreDataManager.h"
#import "MTProjectEditor.h"
#import "MTPassage.h"


@implementation MTTextViewController {
	NSNumber * textSize;
	NSColor * passageColor, * backgroundColor, * linkColor, * macroColor, * imageColor, * htmlColor, * commentColor, * displayColor;
}

NSString * const linkReg = @"\\[\\[([^\\|\\]]*?)(?:(\\]\\])|(\\|(.*?)\\]\\]))";
NSString * const macroReg = @"<<([^>\\s]+)(?:\\s*)((?:[^>]|>(?!>))*)>>";
NSString * const imageReg = @"\\[([<]?)(>?)img\\[(?:([^\\|\\]]+)\\|)?([^\\[\\]\\|]+)\\](?:\\[([^\\]]*)\\]?)?(\\])";
NSString * const htmlReg = @"<html>((?:.|\\n)*?)</html>";
NSString * const commentReg = @"/%((?:.|\\n)*?)%/";
NSString * const displayReg = @"\\<\\<display\\s+[\'\"](.+?)[\'\"]\\s?\\>\\>";


#pragma mark - Lifecycle

- (void)awakeFromNib {
	self.passageTextView.delegate = self;
	
    [[self.passageTextView textStorage] setDelegate:self];
	
	passageColor = [self colorLoadNBind:@"passageColor"];
	backgroundColor = [self colorLoadNBind:@"backgroundColor"];
	linkColor = [self colorLoadNBind:@"linkColor"];
	macroColor = [self colorLoadNBind:@"macroColor"];
	
	imageColor = [self colorLoadNBind:@"imageColor"];
	htmlColor = [self colorLoadNBind:@"htmlColor"];
	commentColor = [self colorLoadNBind:@"commentColor"];
	displayColor = [self colorLoadNBind:@"displayColor"];
	
	textSize = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"textSize"];
	
	[self bind:@"textSize"
	  toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:@"values.textSize"
	   options:@{ @"NSContinuouslyUpdatesValue":@YES }];
}

- (NSColor *)colorLoadNBind:(NSString *)key {
	NSColor * c = [self colorForKey:key];
	[self bind:key
	  toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[NSString stringWithFormat:@"values.%@", key]
	   options:@{ @"NSContinuouslyUpdatesValue":@YES, NSValueTransformerNameBindingOption:NSUnarchiveFromDataTransformerName}];
	return c;
}


#pragma mark - MTTextViewDelegate

- (void)linkMatchMade:(MTTextView *)sender matchedString:(NSString *)matchedString {
	NSAssert(matchedString != nil, @"matchedString is nil");
	//NSLog(@"%s 'Line:%d' - matched string in protocol:'%@'", __func__, __LINE__, matchedString);
	
	// we want to find the passage of the clicked link, and only the part after the pipe
	
    NSArray * shouldBePotentialPassage;
	if ( [matchedString rangeOfString:@"|"].location == NSNotFound ) {
		shouldBePotentialPassage = [matchedString stringsByExtractingGroupsUsingRegexPattern:@"^\\[\\[(.*)\\]\\]$"
                                                                                       caseInsensitive:YES
                                                                                        treatAsOneLine:YES];
    }
    else {
		NSArray * components = [matchedString componentsSeparatedByString:@"|"];
		shouldBePotentialPassage = [components[1] stringsByExtractingGroupsUsingRegexPattern:@"^(.*)\\]\\]$"
                                                                                       caseInsensitive:YES
                                                                                        treatAsOneLine:YES];
	}
    
    if (shouldBePotentialPassage.count == 1) {
        //NSLog(@"%s 'Line:%d' - match regex cleaned to:'%@'", __func__, __LINE__, potentialPassage);
        NSDictionary * d = @{ @"index":shouldBePotentialPassage[0] };
        [[NSNotificationCenter defaultCenter] postNotificationName:MTTextViewControllerDidGetPotentialPassageClickNotification
                                                            object:self
                                                          userInfo:d];
    }
}


#pragma mark - NSTextStorageDelegate

- (void)textStorageDidProcessEditing:(NSNotification *)aNotification {
    
    if (self.passageTextView == nil) { return; }
    
    NSTextStorage * textStorage = self.passageTextView.textStorage;
    NSString * string = textStorage.string;
	NSRange range = NSMakeRange(0, [textStorage length]);
	//NSRange passageRange = NSMakeRange(0, passageString.length);
	//NSLog(@"%s 'Line:%d' - passageRange range:'%lu' textStorage range:'%lu'", __func__, __LINE__, passageRange.length, range.length);
	
	NSFont * font = [[NSFontManager sharedFontManager] fontWithFamily:@"Arial" traits:0 weight:5 size:textSize.floatValue];
	
    // remove previous attributes
    
    [textStorage removeAttribute:NSForegroundColorAttributeName range:range];
    [textStorage removeAttribute:NSBackgroundColorAttributeName range:range];
    [textStorage removeAttribute:kLinkMatch range:range];
    
    // add default attributes
    
	NSDictionary * fullAttributes = @{ NSForegroundColorAttributeName:passageColor, NSBackgroundColorAttributeName:backgroundColor, NSFontSizeAttribute:textSize, NSFontAttributeName:font };
	[textStorage setAttributes:fullAttributes range:range];
	
    // remove links from current passage
    [MTProjectEditor sharedMTProjectEditor].currentPassage.outgoing = [NSSet set];
    
	// highlight
	[self addHighlights:textStorage regex:linkReg string:string range:range color:linkColor isLink:YES];
	[self addHighlights:textStorage regex:macroReg string:string range:range color:macroColor isLink:NO];
	[self addHighlights:textStorage regex:imageReg string:string range:range color:imageColor isLink:NO];
	[self addHighlights:textStorage regex:htmlReg string:string range:range color:htmlColor isLink:NO];
	[self addHighlights:textStorage regex:commentReg string:string range:range color:commentColor isLink:NO];
	[self addHighlights:textStorage regex:displayReg string:string range:range color:displayColor isLink:NO];
}


#pragma mark - Private

- (void)addHighlights:(NSTextStorage *)textStorage regex:(NSString *)expression string:(NSString *)passageString range:(NSRange)passageRange color:(NSColor *)color isLink:(BOOL)linkAttribute {
	NSRegularExpression * regExpression = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:nil];
	[regExpression enumerateMatchesInString:passageString // The string.
									options:0 // The matching options to report. See “NSMatchingOptions” for the supported values.
									  range:passageRange // The range of the string to test.
								 usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
									 
									 NSRange substringRange = result.range;
									 
									 if (linkAttribute) {
                                         NSDictionary * fullAttributes;
										 NSString * substring = [passageString substringWithRange:substringRange];
										 //NSLog(@"%s 'Line:%d' - substring:'%@'", __func__, __LINE__, substring);
										 
                                         // perform a search by passage name from the substring
                                         NSMutableString * searchString = [NSMutableString stringWithString:substring];
                                         [searchString deleteCharactersInRange:NSMakeRange(0, 2)];
                                         [searchString deleteCharactersInRange:NSMakeRange(searchString.length - 2, 2)];
                                         
                                         NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (project == %@)", searchString, [MTProjectEditor sharedMTProjectEditor].currentProject];
                                         NSArray * searchResult = [[MTCoreDataManager sharedMTCoreDataManager] executeFetchWithPredicate:predicate entity:@"Passage"];
                                         
                                         // color and apply link properties for working links vs non working
                                         if (searchResult.count == 1 && [MTProjectEditor sharedMTProjectEditor].currentPassage != nil) {
                                             [[MTProjectEditor sharedMTProjectEditor].currentPassage addOutgoingObject:searchResult[0]];
                                             fullAttributes = @{ NSForegroundColorAttributeName:color, kLinkMatch:substring };
                                         }
                                         else {
                                             fullAttributes = @{ NSForegroundColorAttributeName:[self colorForKey:@"brokenLinkColor"]};
                                         }
										 
										 [textStorage addAttributes:fullAttributes range:substringRange];
										 
									 } else {
										 [textStorage addAttribute:NSForegroundColorAttributeName
															 value:color
															 range:substringRange];
									 }
								 }
	 ];
}

- (NSColor *)colorForKey:(NSString *)key {
    NSColor * color = nil;
	NSData * theData = [[NSUserDefaults standardUserDefaults] dataForKey:key];
	if (theData != nil)
		color = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return color;
}


@end

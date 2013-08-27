/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTextViewController.h"
#import "NSString+PDRegex.h"

@implementation CBTextViewController

NSString * const linkReg = @"\\[\\[([^\\|\\]]*?)(?:(\\]\\])|(\\|(.*?)\\]\\]))";
NSString * const macroReg = @"<<([^>\\s]+)(?:\\s*)((?:[^>]|>(?!>))*)>>";
NSString * const imageReg = @"\\[([<]?)(>?)img\\[(?:([^\\|\\]]+)\\|)?([^\\[\\]\\|]+)\\](?:\\[([^\\]]*)\\]?)?(\\])";
NSString * const htmlReg = @"<html>((?:.|\\n)*?)</html>";
NSString * const commentReg = @"/%((?:.|\\n)*?)%/";
NSString * const displayReg = @"\\<\\<display\\s+[\'\"](.+?)[\'\"]\\s?\\>\\>";

NSColor * linkColor, * macroColor, * imageColor, * htmlColor, * commentColor, * displayColor;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib
{
	self.passageTextView.delegate = self;
	
    [[self.passageTextView textStorage] setDelegate:self];
	
	linkColor = [NSColor blueColor];
	macroColor = [NSColor purpleColor];
	imageColor = [NSColor redColor];
	htmlColor = [NSColor orangeColor];
	commentColor = [NSColor yellowColor];
	displayColor = [NSColor greenColor];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NSTextStorageDelegate Protocol
////////////////////////////////////////////////////////////////////////
- (void)linkMatchMade:(CBTextView *)sender matchedString:(NSString *)matchedString
{
	NSAssert(matchedString != nil, @"matchedString is nil");
    NSLog(@"%s 'Line:%d' - matched string in protocol:'%@'", __func__, __LINE__, matchedString);
	
	// we want to find the passage of the clicked link
	
	if ( [matchedString rangeOfString:@"|"].location == NSNotFound ) {	
		NSArray * shouldBePotentialPassage = [matchedString stringsByExtractingGroupsUsingRegexPattern:@"^\\[\\[(.*)\\]\\]$" caseInsensitive:YES treatAsOneLine:YES];
		for (NSString * potentialPassage in shouldBePotentialPassage) {
			NSLog(@"%s 'Line:%d' - match:'%@'", __func__, __LINE__, potentialPassage);
		}
	} else {
		NSArray * components = [matchedString componentsSeparatedByString:@"|"];
		NSArray * shouldBePotentialPassage = [components[1] stringsByExtractingGroupsUsingRegexPattern:@"^(.*)\\]\\]$" caseInsensitive:YES treatAsOneLine:YES];
		for (NSString * potentialPassage in shouldBePotentialPassage) {
			NSLog(@"%s 'Line:%d' - match:'%@'", __func__, __LINE__, potentialPassage);
		}
	}
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CBTextViewDelegate Protocol
////////////////////////////////////////////////////////////////////////
- (void)textStorageDidProcessEditing:(NSNotification *)aNotification
{
    NSTextStorage * textStorage = [aNotification object];
    NSString * passageString = [textStorage string];
    NSUInteger passageLength = [passageString length];
	NSRange passageRange = NSMakeRange(0, passageLength);
	
	// remove the old colors
    [textStorage removeAttribute:NSForegroundColorAttributeName range:passageRange];
    
	// highlight
	[self performHighlightingOnTextStorage:textStorage regExpression:linkReg passageString:passageString passageRange:passageRange color:linkColor linkAttribute:YES];
	[self performHighlightingOnTextStorage:textStorage regExpression:macroReg passageString:passageString passageRange:passageRange color:macroColor linkAttribute:NO];
	[self performHighlightingOnTextStorage:textStorage regExpression:imageReg passageString:passageString passageRange:passageRange color:imageColor linkAttribute:NO];
	[self performHighlightingOnTextStorage:textStorage regExpression:htmlReg passageString:passageString passageRange:passageRange color:htmlColor linkAttribute:NO];
	[self performHighlightingOnTextStorage:textStorage regExpression:commentReg passageString:passageString passageRange:passageRange color:commentColor linkAttribute:NO];
	[self performHighlightingOnTextStorage:textStorage regExpression:displayReg passageString:passageString passageRange:passageRange color:displayColor linkAttribute:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (void)performHighlightingOnTextStorage:(NSTextStorage *)textStorage regExpression:(NSString *)expression passageString:(NSString *)passageString passageRange:(NSRange)passageRange color:(NSColor *)color linkAttribute:(BOOL)linkAttribute {
	
	NSRegularExpression * regExpression = [NSRegularExpression regularExpressionWithPattern:expression
																					options:0
																					  error:nil];
	
	[regExpression enumerateMatchesInString:passageString // The string.
									options:0 // The matching options to report. See “NSMatchingOptions” for the supported values.
									  range:passageRange // The range of the string to test.
								 usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {

									 NSRange substringRange = result.range;
									 
									 if (linkAttribute) {
										NSString * substring = [passageString substringWithRange:substringRange];
										 //NSLog(@"%s 'Line:%d' - substring:'%@'", __func__, __LINE__, substring);
										 
										 NSDictionary *fullAttributes = @{ NSForegroundColorAttributeName:color, kLinkMatch:substring };
										 [textStorage addAttributes:fullAttributes range:substringRange];
										 
									 } else {
										 [textStorage addAttribute:NSForegroundColorAttributeName
															 value:color
															 range:substringRange];
									 }
								 }
	 ];
}

@end

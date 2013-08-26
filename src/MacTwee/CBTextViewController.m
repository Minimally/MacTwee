/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTextViewController.h"

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
    [[self.passageTextView textStorage] setDelegate:self];
	
	linkColor = [NSColor blueColor];
	macroColor = [NSColor purpleColor];
	imageColor = [NSColor redColor];
	htmlColor = [NSColor orangeColor];
	commentColor = [NSColor yellowColor];
	displayColor = [NSColor greenColor];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Protocol
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
	[self performHighlightingOnTextStorage:textStorage regExpression:linkReg passageString:passageString passageRange:passageRange color:linkColor];
	[self performHighlightingOnTextStorage:textStorage regExpression:macroReg passageString:passageString passageRange:passageRange color:macroColor];
	[self performHighlightingOnTextStorage:textStorage regExpression:imageReg passageString:passageString passageRange:passageRange color:imageColor];
	[self performHighlightingOnTextStorage:textStorage regExpression:htmlReg passageString:passageString passageRange:passageRange color:htmlColor];
	[self performHighlightingOnTextStorage:textStorage regExpression:commentReg passageString:passageString passageRange:passageRange color:commentColor];
	[self performHighlightingOnTextStorage:textStorage regExpression:displayReg passageString:passageString passageRange:passageRange color:displayColor];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
- (void)performHighlightingOnTextStorage:(NSTextStorage *)textStorage regExpression:(NSString *)expression passageString:(NSString *)passageString passageRange:(NSRange)passageRange color:(NSColor *)color {
	
	NSRegularExpression * regExpression = [NSRegularExpression regularExpressionWithPattern:expression
																					options:0
																					  error:nil];
	
	[regExpression enumerateMatchesInString:passageString // The string.
									options:0 // The matching options to report. See “NSMatchingOptions” for the supported values.
									  range:passageRange // The range of the string to test.
								 usingBlock:^(NSTextCheckingResult * result, NSMatchingFlags flags, BOOL * stop) {
									 // result - An NSTextCheckingResult specifying the match. This result gives the overall matched range via its range property, and the range of each individual capture group via its rangeAtIndex: method. The range {NSNotFound, 0} is returned if one of the capture groups did not participate in this particular match.
									 // flags - The current state of the matching progress. See “NSMatchingFlags” for the possible values.
									 // stop - A reference to a Boolean value. The Block can set the value to YES to stop further processing of the array. The stop argument is an out-only argument. You should only ever set this Boolean to YES within the Block.
									 
									 NSRange substringRange = result.range;
									 //NSString * substring = [passageString substringWithRange:substringRange];
									 //NSLog(@"%s 'Line:%d' - substring:'%@'", __func__, __LINE__, substring);
									 [textStorage addAttribute:NSForegroundColorAttributeName
														 value:color
														 range:substringRange];
								 }
	 ];
}

@end

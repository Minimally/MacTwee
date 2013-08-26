/*
 Copyright (c) 2013 Chris Braithwaite. All rights reserved.
 */

#import "CBTweeImportUtility.h"
#import "NSString+PDRegex.h" // for parsing
#import "CBProjectEditor.h"
#import "CBPassage.h"
#import "CBProject.h"

@implementation CBTweeImportUtility

NSString * const kOpenMessage = @"Choose a twee source file to import";

NSString * const regPatternForHeadBodySplit = @":* ([^\n]*)\n(.*)?";
NSString * const regPatternForTitleTagSplit = @"^:* *(.+) \\[(.+)\\].*$";
NSString * const regPatternForTitleGet = @"^:* *(.+) *$";

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////
- (void)importTweeFile {
	//open up a source file
	NSURL * url = [self importFileUrlFromDialogue];
	if (url == nil) {
		[self operationResult:[NSString stringWithFormat:@"issue with open dialogue url:'%@'", url]];
		return;
	}
	
	NSString * sourceFileString = [self getImportFileAsString:url];
	if (sourceFileString == nil || sourceFileString.length == 0 ) {
		[self operationResult:[NSString stringWithFormat:@"issue with string from open dialogue url:'%@'", url]];
		return;
	}
	
	[self sourceFileSplit:sourceFileString];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Import - String to Passage
////////////////////////////////////////////////////////////////////////
- (NSString *)getImportFileAsString:(NSURL *)url {
	NSString * s;
	s = [NSString stringWithContentsOfURL:url
								 encoding:NSUTF8StringEncoding
									error:nil];
	return s;
}
- (void)sourceFileSplit:(NSString *)sourceFileString {
	NSArray * passages = [sourceFileString componentsSeparatedByString:@"\n::"];
	//NSLog(@"passages count '%lu'", (unsigned long)passages.count);
	
	for (NSString * passage in passages) {
		//NSLog(@"%s 'Line:%d' - split passage text:'%@'", __func__, __LINE__, passage);
		[self passageToHeadAndBody:passage];
	}
}
- (void)passageToHeadAndBody:(NSString *)passageString {
	NSAssert((passageString != nil || passageString.length > 0), @"string is nil or empty");
	if (passageString == nil || passageString.length == 0)
		return;
	
	NSArray * passageBits = [passageString stringsByExtractingGroupsUsingRegexPattern:regPatternForHeadBodySplit
																caseInsensitive:YES
																 treatAsOneLine:YES];
	
	//NSLog(@"%s 'Line:%d' - sub passages count:'%lu'", __func__, __LINE__, (unsigned long)passageBits.count);
	switch (passageBits.count) {
		case 0: {
			break;
		}
		case 1: {
			[self preparePassageWithHead:passageBits[0] body:nil];
			break;
		}
		case 2: {
			[self preparePassageWithHead:passageBits[0] body:passageBits[1]];
			break;
		}
		default:break;
	}
}
- (void)preparePassageWithHead:(NSString *)passageHead body:(NSString *)passageBody {
	//NSLog(@"%s 'Line:%d' - HEAD:'%@'", __func__, __LINE__, passageHead);
	NSString * title, * tags, * body;
	
	//get title and tags from passageHead
	if ([passageHead rangeOfString:@"["].location != NSNotFound)
	{
		// this head contains tags
		NSArray * headBits = [passageHead stringsByExtractingGroupsUsingRegexPattern:regPatternForTitleTagSplit
																	 caseInsensitive:YES
																	  treatAsOneLine:YES];
		NSAssert(headBits.count > 0, @"headBits is less than zero");
		if (headBits.count > 1) {
			title = headBits[0];
			tags = headBits[1];
		}
		//NSLog(@"%s 'Line:%d' - title:'%@'", __func__, __LINE__, title);
		//NSLog(@"%s 'Line:%d' - tags:'%@'", __func__, __LINE__, tags);
	} else {
		// this head does not contain tags
		NSArray * headBits = [passageHead stringsByExtractingGroupsUsingRegexPattern:regPatternForTitleGet
																	 caseInsensitive:YES
																	  treatAsOneLine:YES];
		NSAssert(headBits.count > 0, @"headBits is less than zero");
		if (headBits.count > 0) {
			title = headBits[0];
		}
		//NSLog(@"%s 'Line:%d' - title:'%@'", __func__, __LINE__, title);
	}
	
	//NSLog(@"%s 'Line:%d' - BODY:'%@'", __func__, __LINE__, passageBody);
	body = passageBody;
	
	[self createAPassageWithTitle:title
							 tags:tags
							 body:body];
}
- (void)createAPassageWithTitle:(NSString *)passageTitle tags:(NSString *)passageTags body:(NSString *)passageBody {
	NSAssert(passageTitle != nil, @"passageTitle is nil");
	if (passageTitle != nil) {
		[[CBProjectEditor sharedCBProjectEditor] createPassageWithTitle:passageTitle
																andTags:passageTags
																andText:passageBody];
	}
}

////////////////////////////////////////////////////////////////////////
#pragma mark - User Dialogues
////////////////////////////////////////////////////////////////////////
- (NSURL *)importFileUrlFromDialogue {
	NSURL * result;
	
	NSArray *fileTypesArray = @[ @"txt", @"twee", @"tw" ];
	
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.message = kOpenMessage;
	openPanel.allowedFileTypes = fileTypesArray;
	openPanel.canChooseFiles = YES;
	openPanel.canChooseDirectories = NO;
	openPanel.resolvesAliases = YES;
	
	if ( [openPanel runModal] == NSOKButton ) {
		if ([[openPanel URL] isFileURL]) {
			NSLog(@"%s 'Line:%d' - Open File path: %@", __func__, __LINE__, [openPanel.URLs[0] path]);
			result = openPanel.URL;
		}
	} else {
		NSLog(@"%s 'Line:%d' - Operation Cancled by user", __func__, __LINE__);
	}
	
	return result;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Result
////////////////////////////////////////////////////////////////////////

- (void)operationResult:(NSString *)result {
	NSLog(@"%s 'Line:%d' - %@", __func__, __LINE__, result);
}

@end

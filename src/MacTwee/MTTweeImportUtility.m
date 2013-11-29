//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTTweeImportUtility.h"
#import "NSString+PDRegex.h" // for parsing
#import "MTProjectEditor.h"
#import "MTPassage.h"
#import "MTProject.h"


@implementation MTTweeImportUtility

NSString * const regPatternForHeadBodySplit = @":* ([^\n]*)\n(.*)?";
NSString * const regPatternForTitleTagSplit = @"^:* *(.+) \\[(.+)\\].*$";
NSString * const regPatternForTitleGet = @"^:* *(.+) *$";


#pragma mark - Public

- (int)importTweeFile:(NSURL *)file toProject:(MTProject *)project {
    NSAssert(file != nil, @"file is nil");
    NSAssert(project != nil, @"project is nil");
    
    int result = 0;
    
    NSString * string = [self stringFromFileAtURL:file];
    if (string == nil || string.length == 0 ) {
		[self operationResultWithTitle:@"Error" msgFormat:[NSString stringWithFormat:@"Couldn't create string from file at '%@'", file] defaultButton:@"OK"];
    }
    else {
        result = [self buildPassagesFromString:string toProject:project];
        [self operationResultWithTitle:@"Success" msgFormat:[NSString stringWithFormat:@"Imported %i Passages", result] defaultButton:@"OK"];
    }
    
    return result;
}


#pragma mark - Prepare File

/// create a NSString from the contents of a file @param url the NSURL for the file
- (NSString *)stringFromFileAtURL:(NSURL *)url {
	NSString * s;
	s = [NSString stringWithContentsOfURL:url
								 encoding:NSUTF8StringEncoding
									error:nil];
	return s;
}


#pragma mark - Parse File

/// gets all MTPassage from sent in NSString, and adds them to sent in MTProject @returns successfully created passages count
- (int)buildPassagesFromString:(NSString *)string toProject:(MTProject *)project {
    NSAssert(string != nil, @"string is nil");
    NSAssert(project != nil, @"project is nil");
    int result = 0;
    NSArray * separatedStrings = [string componentsSeparatedByString:@"\n::"];
    
    if (separatedStrings.count == 0) {
		[self operationResultWithTitle:@"Error" msgFormat:@"Zero passages found from file" defaultButton:@"OK"];
	}
    
    else {
        for (NSString * separatedString in separatedStrings) {
            MTPassage * passage = [self passageFromString:separatedString];
            
            if (passage != nil) { result++; }
            
            [project addPassagesObject:passage];
        }
	}
    
    return result;
}

/// turns a NSString into a MTPassage @returns created MTPassage or nil if parsing failed
- (MTPassage *)passageFromString:(NSString *)string {
    MTPassage * result;
    
    NSArray * stringHeadBody = [string stringsByExtractingGroupsUsingRegexPattern:regPatternForHeadBodySplit
                                                                  caseInsensitive:YES
                                                                   treatAsOneLine:YES];
    
    if (stringHeadBody.count == 1) { // found one piece, could be head or body ?
        result = [self preparePassageWithHead:stringHeadBody[0] body:nil];
    }
    
    else if (stringHeadBody.count == 2) { // found two pieces, head and body
        result = [self preparePassageWithHead:stringHeadBody[0] body:stringHeadBody[1]];
    }
    
    else { // there was some error with the regex
        
    }
    
    return result;
}

- (MTPassage *)preparePassageWithHead:(NSString *)passageHead body:(NSString *)passageBody {
    MTPassage * result;
	NSString * title, * tags, * body;
	
	if ( [passageHead rangeOfString:@"["].location != NSNotFound ) { // there are tags in the passage header
		
		NSArray * headBits = [passageHead stringsByExtractingGroupsUsingRegexPattern:regPatternForTitleTagSplit
																	 caseInsensitive:YES
																	  treatAsOneLine:YES];
		
        if (headBits.count == 2) {
			title = headBits[0];
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			tags = headBits[1];
            tags = [tags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
        else { // there was some error with the regex
            
        }
	}
    
    else { // this header does not contain tags
        
		NSArray * headBits = [passageHead stringsByExtractingGroupsUsingRegexPattern:regPatternForTitleGet
																	 caseInsensitive:YES
																	  treatAsOneLine:YES];
        
		if (headBits.count == 1) {
			title = headBits[0];
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
		else { // there was some error with the regex
            
        }
	}
	
	body = passageBody;
    if ( passageBody != nil && passageBody.length > 0) {
        body = [body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
	
	result = [self createAPassageWithTitle:title tags:tags body:body];
    return result;
}

- (MTPassage *)createAPassageWithTitle:(NSString *)passageTitle tags:(NSString *)passageTags body:(NSString *)passageBody {
	MTPassage * result;
    
	if (passageTitle != nil) {
        result = [MTPassage passage];
        result.title = passageTitle;
        result.passageTags = passageTags;
        result.text = passageBody;
	}
    
    return result;
}


#pragma mark - Result

- (void)operationResultWithTitle:(NSString *)title msgFormat:(NSString *)msgFormat defaultButton:(NSString *)defaultButton {
	NSRunAlertPanel(title, msgFormat, defaultButton, nil, nil);
	//[self operationResultWithTitle:@"Error" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
	//[self operationResultWithTitle:@"Success" msgFormat:@"EXAMPLE" defaultButton:@"OK"];
    if ([title isEqualToString:@"Success"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:MTTweeImporUtilityDidImportFile object:self];
    }
}


@end

//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import "MTProjectEditor.h"
#import "MTCoreDataManager.h"
#import "MTProject.h"
#import "MTPassage.h"


@implementation MTProjectEditor

#pragma mark - Lifecycle

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(MTProjectEditor);

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(processNotification:)
                                                     name:MTTweeBuildUtilityDidGetProjectBuildDestination
                                                   object:nil];
    }
    return self;
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }

- (void)processNotification:(NSNotification *)notification {
    if ( [notification.name isEqualToString:MTTweeBuildUtilityDidGetProjectBuildDestination] ) {
        NSURL * url = notification.userInfo[@"index"];
        if (url != nil) {
            self.currentProject.buildDirectory = url.path;
            self.currentProject.buildName = url.lastPathComponent;
        }
    }
}

#pragma mark - Public

- (void)newPassage {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
    
    NSString * passageName = @"New Passage";
    while ( [self checkPassageExistsInCurrentProject:passageName] ) {
        passageName = [self uniquePassageName:passageName];
    }
    
	MTPassage * passage = [self createPassageWithTitle:passageName andTags:nil andText:nil];
    
    self.currentPassage = passage;
}

- (MTPassage *)createPassageWithTitle:(NSString *)title andTags:(NSString *)tags andText:(NSString *)text {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	
    NSString * uniqueTitle = title;
    while ( [self checkPassageExistsInCurrentProject:uniqueTitle] ) {
        uniqueTitle = [self uniquePassageName:uniqueTitle];
    }
    
    MTPassage * passage = [MTPassage passage];
	passage.title = uniqueTitle;
	passage.passageTags = tags;
	passage.text = text;
	passage.project = self.currentProject;
    return passage;
}

- (MTPassage *)createPassageAtXPos:(NSNumber *)xPos yPos:(NSNumber *)yPos {
	MTPassage * passage = [MTPassage passage];
    passage.xPosition = xPos;
    passage.yPosition = yPos;
    
    NSString * uniqueTitle = @"New Passage";
    while ( [self checkPassageExistsInCurrentProject:uniqueTitle] ) {
        uniqueTitle = [self uniquePassageName:uniqueTitle];
    }
    
    passage.title = uniqueTitle;
	passage.project = self.currentProject;
    return passage;
    
}
///returns a string with one attached to it
- (NSString *)uniquePassageName:(NSString *)baseString {
    NSString * result = [NSString stringWithFormat:@"%@ 2",baseString];
    return result;
}

- (NSString *)getStoryFormat {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	return self.currentProject.storyFormat;
}

- (NSArray *)getPassages {
	return [self.currentProject.passages allObjects];
}

- (BOOL)checkPassageExistsInCurrentProject:(NSString *)passage {
    BOOL result = ( [self getPassageWithName:passage] == nil ) ? NO : YES;
	//NSLog(@"%d | %s - passage:'%@' exists", __LINE__, __func__, passage);
	return result;
}

- (BOOL)selectCurrentPassageWithName:(NSString *)passage {
	BOOL result = NO;
	
	if ( ![self checkPassageExistsInCurrentProject:passage] ) {
		result = NO;
	} else {
		MTPassage * p = [self getPassageWithName:passage];
		if (p != nil) {
			self.currentPassage = p;
			result = YES;
		}
	}
	
	return result;
}

- (void)ResetCurrentValues {
    self.currentProject = nil;
    self.currentPassage = nil;
}

- (void)setupCurrentProject:(MTProject *)project {
    if (project!=nil) {
        self.currentProject = project;
    }
    for (MTPassage * passage in self.currentProject.passages) {
        [passage populateLinks];
    }
}

- (void)updateCurrentProject {
    if (self.currentProject == nil) { return; }
    for (MTPassage * passage in self.currentProject.passages) {
        [passage populateLinks];
    }
}

- (void)applyExportRules {
    for (MTPassage * passage in self.currentProject.passages) {        
        if (passage.text == nil || passage.text.length == 0) { return; }
        
        NSMutableString * text = [NSMutableString stringWithString:passage.text];
        NSRange range = NSMakeRange(0, text.length);
        
        // Unicode Character 'LEFT DOUBLE QUOTATION MARK' (U+201C)
        [text replaceOccurrencesOfString:@"“"
                              withString:@"\""
                                 options:NSLiteralSearch
                                   range:range];
        // Unicode Character 'RIGHT DOUBLE QUOTATION MARK' (U+201D)
        [text replaceOccurrencesOfString:@"”"
                              withString:@"\""
                                 options:NSLiteralSearch
                                   range:range];
        
        // Unicode Character 'LEFT SINGLE QUOTATION MARK' (U+2018)
        [text replaceOccurrencesOfString:@"‘"
                              withString:@"'"
                                 options:NSLiteralSearch
                                   range:range];
        // Unicode Character 'RIGHT SINGLE QUOTATION MARK' (U+2019)
        [text replaceOccurrencesOfString:@"’"
                              withString:@"'"
                                 options:NSLiteralSearch
                                   range:range];
        
        // Unicode Character 'EM SPACE' (U+2003)
        /*[text replaceOccurrencesOfString:@" " withString:@" " options:NSLiteralSearch range:range]; */
        
        
        // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
        [text replaceOccurrencesOfString:@"…"
                              withString:@"..."
                                 options:NSLiteralSearch
                                   range:range];
        
        // Unicode Character 'EN DASH' (U+2013)
        [text replaceOccurrencesOfString:@"–"
                              withString:@"-"
                                 options:NSLiteralSearch
                                   range:range];
        
        // Unicode Character 'EM DASH' (U+2014)
        [text replaceOccurrencesOfString:@"—"
                              withString:@"--"
                                 options:NSLiteralSearch
                                   range:range];
        
        
        
        passage.text = text;
    }
}

#pragma mark - Private

- (void)setCurrentProject:(MTProject *)proj {
	_currentProject = proj;
	_currentProject.lastModifiedDate = [NSDate date];
}

- (void)setCurrentPassage:(MTPassage *)passage {
	[self willChangeValueForKey:@"currentPassage"];
    _currentPassage = nil;
    if ( passage != nil ) {
        _currentPassage = passage;
        _currentPassage.lastModifiedDate = [NSDate date];
    }
	[self didChangeValueForKey:@"currentPassage"];
}

/*! searches for a MTPassage using the sent in string in core data @param passage - title of the passage @returns an MTPassage if successful else nil */

- (MTPassage *)getPassageWithName:(NSString *)passageTitle {
	NSAssert(self.currentProject != nil, @"currentProject is nil");
	MTPassage * result;
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(title == %@) AND (project == %@)", passageTitle, self.currentProject];
	NSArray * foundPassages = [MTCoreDataManager.sharedMTCoreDataManager executeFetchWithPredicate:predicate entity:@"Passage"];
	//NSLog(@"%s 'Line:%d' - found:'%lu'", __func__, __LINE__, foundPassages.count);
	if (foundPassages.count > 0) {
		result = foundPassages[0];
	}
	return result;
}


@end

//
//  MTTweeExportUtilityTests.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/29/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <XCTest/XCTest.h>
#import "MTTweeExportUtility.h"
#import "MTProject.h"
#import "MTPassage.h"
#import "MTConstants.h"

@interface MTTweeExportUtilityTests : XCTestCase

@end

@implementation MTTweeExportUtilityTests {
    MTTweeExportUtility * exporter;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    exporter = [[MTTweeExportUtility alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    exporter = nil;
    [super tearDown];
}

- (void)test_exportTweeFileFromProject {
    NSString * fileName = @"storyTest.twee";
    NSString * destinationPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], fileName];
    NSURL * destinationURL = [NSURL fileURLWithPath:destinationPath];
    
    MTProject * project = [MTProject project];
    MTPassage * passage = [MTPassage passage];
    [project addPassagesObject:passage];
    passage.title = @"Start";
    passage.text = @"This is the start of the story";
    
    NSURL * result = [exporter exportTweeFileFromProject:project toDestination:destinationURL];
    XCTAssertTrue( [result.path isEqualToString:destinationPath] , @"ORIGINAL PATH AND RESULT PATH DO NOT MATCH");
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:NO];
    if ( exists ) {
        NSLog(@"%d | %s - File existed at path:'%@'", __LINE__, __func__, destinationPath);
        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    }
    XCTAssertTrue( result , @"FILE DID EXIST");
}

- (void)test_exportScratchTweeFileFromProject {
    NSURL * destinationURL = [self getScratchLocationForExport];
    NSString * destinationPath = destinationURL.path;
    
    MTProject * project = [MTProject project];
    MTPassage * passage = [MTPassage passage];
    [project addPassagesObject:passage];
    passage.title = @"Start";
    passage.text = @"This is the start of the story";
    
    NSURL * result = [exporter exportScratchTweeFileFromProject:project];
    XCTAssertTrue( [result.path isEqualToString:destinationPath] , @"ORIGINAL PATH AND RESULT PATH DO NOT MATCH");
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:NO];
    if ( exists ) {
        NSLog(@"%d | %s - File existed at path:'%@'", __LINE__, __func__, destinationPath);
        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    }
    XCTAssertTrue( result , @"FILE DID EXIST");
}

#pragma mark - Utility

- (NSURL *)getScratchLocationForExport {
	NSURL * result;
	NSFileManager * fileManager = [NSFileManager defaultManager];
    NSURL * appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSString * tempPath = [NSString stringWithFormat:@"%@/temp.tw", kUserApplicationSupportDirectory];
    result = [appSupportURL URLByAppendingPathComponent:tempPath];
	return result;
}

@end

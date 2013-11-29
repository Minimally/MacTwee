//
//  MTImportUtilityTests.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/29/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <XCTest/XCTest.h>
#import "MTTweeImportUtility.h"
#import "MTProject.h"
#import "MTPassage.h"

@interface MTTweeImportUtilityTests : XCTestCase

@end

@implementation MTTweeImportUtilityTests {
    MTTweeImportUtility * importer;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    importer = [[MTTweeImportUtility alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    importer = nil;
    [super tearDown];
}

- (void)test_exportTweeFileFromProject {
    NSURL * sourceDir = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    MTProject * project = [MTProject project];
    
    int result = [importer importTweeFile:sourceDir toProject:project];
    
    XCTAssertTrue(result == 5, @"EXPECTED 5 PASSAGES AS IMPORT RESULT");
    XCTAssertTrue(project.passages.count == 5, @"EXPECTED 5 PASSAGES IN THE PROJECT");
}

@end

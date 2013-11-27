//
//  MTBuildUtilityTests.m
//  MacTwee
//
//  Created by Chris Braithwaite on 11/27/13.
//  Copyright (c) 2013 MacTwee. Released under MIT License.
//

#import <XCTest/XCTest.h>
#import "MTTweeBuildUtility.h"

@interface MTTweeBuildUtilityTests : XCTestCase

@end

@implementation MTTweeBuildUtilityTests {
    MTTweeBuildUtility * builder;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    builder = [[MTTweeBuildUtility alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    builder = nil;
}

- (void)test_buildHtmlFileWithSource_NoDestination {
    NSURL * sampleTweeFile = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    BOOL result = [builder buildHtmlFileWithSource:sampleTweeFile
                                    buildDirectory:@""
                                     buildFileName:@"testFile.html"
                                       storyFormat:@"sugarcane"
                                        quickBuild:YES];
    
    XCTAssertFalse(result, @"fail");
}

- (void)test_buildHtmlFileWithSource_NoFile {
    NSURL * sampleTweeFile = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    BOOL result = [builder buildHtmlFileWithSource:sampleTweeFile
                                    buildDirectory:@"some directory that shouldn't ever exist I think"
                                     buildFileName:@""
                                       storyFormat:@"sugarcane"
                                        quickBuild:YES];
    
    XCTAssertFalse(result, @"fail");
}

- (void)test_buildHtmlFileWithSource_NoHeader {
    NSURL * sampleTweeFile = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirectory = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    
    BOOL result = [builder buildHtmlFileWithSource:sampleTweeFile
                                    buildDirectory:buildDirectory
                                     buildFileName:buildfileName
                                       storyFormat:@""
                                        quickBuild:YES];
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:buildDirectory isDirectory:NO] ) {
        [[NSFileManager defaultManager] removeItemAtPath:buildDirectory error:nil];
    }
    
    XCTAssertTrue(result, @"fail");
}

- (void)test_buildHtmlFileWithSource {
    NSURL * sampleTweeFile = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirectory = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    
    [builder buildHtmlFileWithSource:sampleTweeFile
                                    buildDirectory:buildDirectory
                                     buildFileName:buildfileName
                                       storyFormat:@"sugarcane"
                                        quickBuild:YES];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:buildDirectory isDirectory:NO];
    if (result) {
        [[NSFileManager defaultManager] removeItemAtPath:buildDirectory error:nil];
    }
    XCTAssertTrue(result, @"fail");
}



@end

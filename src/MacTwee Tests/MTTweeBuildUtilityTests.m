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
    
    builder = nil;
    [super tearDown];
}

- (void)test_buildHtmlFileWithSource {
    NSURL * sourceDir = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    NSURL * buildDir = [NSURL fileURLWithPath:buildDirPath];
    
    NSString * format = @"sugarcane";
    
    BOOL quickBuild = YES;
    
    [builder buildHtmlFileWithSource:sourceDir
                      buildDirectory:buildDir
                         storyFormat:format
                          quickBuild:quickBuild];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:buildDirPath isDirectory:NO];
    
    if ( result ) {
        NSLog(@"%d | %s - build directory:'%@'", __LINE__, __func__, buildDirPath);
        [[NSFileManager defaultManager] removeItemAtPath:buildDirPath error:nil];
    }
    
    XCTAssertTrue(result, @"FILE DID NOT EXIST");
}

- (void)test_buildHtmlFileWithSource_NoSourceAlert {
    NSURL * sourceDir;
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    NSURL * buildDir = [NSURL fileURLWithPath:buildDirPath];
    
    NSString * format = @"sugarcane";
    
    BOOL quickBuild = YES;
    
    [builder buildHtmlFileWithSource:sourceDir
                      buildDirectory:buildDir
                         storyFormat:format
                          quickBuild:quickBuild];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:buildDirPath isDirectory:NO];
    
    if ( result ) {
        [[NSFileManager defaultManager] removeItemAtPath:buildDirPath error:nil];
    }
    
    XCTAssertFalse(result, @"FILE DID EXIST");
}

- (void)test_buildHtmlFileWithSource_NoDestinationPrompt {
    NSURL * sourceDir = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    NSURL * buildDir;
    
    NSString * format = @"sugarcane";
    
    BOOL quickBuild = YES;
    
    [builder buildHtmlFileWithSource:sourceDir
                      buildDirectory:buildDir
                         storyFormat:format
                          quickBuild:quickBuild];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:buildDirPath isDirectory:NO];
    
    if ( result ) {
        [[NSFileManager defaultManager] removeItemAtPath:buildDirPath error:nil];
    }
    
    XCTAssertFalse(result, @"FILE DID EXIST");
}

- (void)test_buildHtmlFileWithSource_NoFormat {
    NSURL * sourceDir = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    NSURL * buildDir = [NSURL fileURLWithPath:buildDirPath];
    
    NSString * format;
    
    BOOL quickBuild = YES;
    
    [builder buildHtmlFileWithSource:sourceDir
                      buildDirectory:buildDir
                         storyFormat:format
                          quickBuild:quickBuild];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:buildDirPath isDirectory:NO];
    
    if ( result ) {
        NSLog(@"%d | %s - build directory:'%@'", __LINE__, __func__, buildDirPath);
        [[NSFileManager defaultManager] removeItemAtPath:buildDirPath error:nil];
    }
    
    XCTAssertTrue(result, @"FILE DID NOT EXIST");
}

- (void)test_buildHtmlFileWithSource_QuickBuildOff {
    NSURL * sourceDir = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"twee"];
    
    NSString * buildfileName = @"testFile.html";
    NSString * buildDirPath = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] bundlePath], buildfileName];
    NSURL * buildDir = [NSURL fileURLWithPath:buildDirPath];
    
    NSString * format = @"sugarcane";
    
    BOOL quickBuild = NO;
    
    [builder buildHtmlFileWithSource:sourceDir
                      buildDirectory:buildDir
                         storyFormat:format
                          quickBuild:quickBuild];
    
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:buildDirPath isDirectory:NO];
    
    if ( result ) {
        NSLog(@"%d | %s - build directory:'%@'", __LINE__, __func__, buildDirPath);
        [[NSFileManager defaultManager] removeItemAtPath:buildDirPath error:nil];
    }
    
    XCTAssertFalse(result, @"FILE DID NOT EXIST");
}


@end

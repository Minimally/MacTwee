//
//  MacTwee
//
//  Created by Chris Braithwaite on 11/23/13.
//  Copyright 2013 Chris Braithwaite. Released under MIT License.
//

#import <XCTest/XCTest.h>
#import "MTProjectEditor.h"


@interface MTProjectEditorTests : XCTestCase

@end


@implementation MTProjectEditorTests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    
    [super tearDown];
}

- (void)test_ResetCurrentValues
{
    [[MTProjectEditor sharedMTProjectEditor] ResetCurrentValues];
    XCTAssertNil([MTProjectEditor sharedMTProjectEditor].currentProject, @"currentProject is not nil");
}


@end

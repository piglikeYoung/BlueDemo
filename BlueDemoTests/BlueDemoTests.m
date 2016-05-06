//
//  BlueDemoTests.m
//  BlueDemoTests
//
//  Created by piglikeyoung on 15/10/14.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BlueDemoTests : XCTestCase

@end

@implementation BlueDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testOnePlusOneEqualsTwo {
    XCTAssertEqual(1 + 1, 2, "one plus one should equal two");
}

@end

//
//  RunTimeTests.m
//  RunTimeTests
//
//  Created by hanling on 2022/8/30.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "TestClass.h"

@interface RunTimeTests : XCTestCase

@end

@implementation RunTimeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    
    Ivar name = class_getInstanceVariable([TestClass class],"name");    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

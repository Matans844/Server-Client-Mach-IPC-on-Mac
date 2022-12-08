//
//  UnitTestDatabase.m
//  UnitTestDatabase
//
//  Created by matan on 07/12/2022.
//

#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "MessageMaker.h"

@interface UnitTestDataManager : XCTestCase

@property DataManager * dataManager;
@property MessageMaker * messageMaker;

@end

@implementation UnitTestDataManager

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    _dataManager = [[DataManager alloc] init];
    // [_dataManager initiate];
    _messageMaker = [[MessageMaker alloc] init];
    // [_messageMaker initiate];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDataManagerVacancy {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSPortMessage * exampleMessage = [_messageMaker createStringMessage:@"test1"];
    
    XCTAssertTrue([_dataManager isDataValid:exampleMessage]);
    XCTAssertTrue([_dataManager isStorageVacant:exampleMessage.sendPort]);
    
    XCTAssertTrue([_dataManager saveData:exampleMessage]);
    
    XCTAssertFalse([_dataManager isStorageVacant:exampleMessage.sendPort]);
    
    NSPortMessage * exampleMessage2 = [_messageMaker createStringMessage:@"test2"];
    XCTAssertFalse([_dataManager isStorageVacant:exampleMessage2.sendPort]);
}

- (void) testDataManagerValidation{
    NSPortMessage * tooBigMessage = [_messageMaker createGarbageDataMessageWithSize:1028];
    
    XCTAssertFalse([_dataManager isDataValid:tooBigMessage]);
    
    XCTAssertFalse([_dataManager saveData:tooBigMessage]);
    
    XCTAssertTrue([_dataManager isStorageVacant:tooBigMessage.sendPort]);
}

- (void) testDataManagerGetData{
    NSPortMessage * exampleMessage = [_messageMaker createStringMessage:@"test1"];
    NSArray * originalComponent = exampleMessage.components;
    
    XCTAssertTrue([_dataManager saveData:exampleMessage]);
    NSArray * receivedComponent = [_dataManager getData:exampleMessage.sendPort];
    
    XCTAssertEqualObjects(receivedComponent[0], originalComponent[0]);
}

- (void) testDataManagerRemoveData{
    NSPortMessage * exampleMessage = [_messageMaker createStringMessage:@"test1"];
    NSPort * sender = exampleMessage.sendPort;
    
    XCTAssertTrue([_dataManager isStorageVacant:exampleMessage.sendPort]);
    
    XCTAssertTrue([_dataManager saveData:exampleMessage]);
    
    XCTAssertFalse([_dataManager isStorageVacant:exampleMessage.sendPort]);
    
    [_dataManager removeData:sender];
    XCTAssertTrue([_dataManager isStorageVacant:sender]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

//
//  UnitTestDatabase.m
//  UnitTestDatabase
//
//  Created by matan on 07/12/2022.
//

#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "MessageHandler.h"
#import "ValidationHandler.h"

@interface UnitTestDataManager : XCTestCase

@property DataManager * dataManager;
@property MessageHandler * messageHandler;
@property ValidationHandler * validationHandler;

@end

// ------------------------------------ //

// So that we can test private methods
@interface DataManager (Testing)
// "Private" methods
- (BOOL) isStorageVacantForSender:(NSPort *)senderPort;
- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode;
- (void) addToDictHashToComponents:(NSData *)hashCode withComponents:(NSArray *)components;
- (void) initiateWith: (MessageHandler * _Nullable) messageManager;
@end

// ------------------------------------ //

@implementation UnitTestDataManager

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    _validationHandler = [[ValidationHandler alloc] init];
    _messageHandler = [[MessageHandler alloc] init];
    _dataManager = [[DataManager alloc] initWithMessageManager:_messageHandler];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// ------------------------------------ //
// Segment for functional test cases.
// Use XCTAssert and related functions to verify your tests produce the correct results.

- (void) testValidationHandler {
    // Testing that the message is in the agreed upon structure, and that it is in the proper size
    NSPortMessage * messageNonStructured = [_messageHandler createDefaultStringMessage:@"test1" isArrayArrangementStructured:NO];
    NSPortMessage * messageStructured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    NSPortMessage * messageTooBig = [_messageHandler createDefaultGarbageDataMessageWithSize:1028 isArrayArrangementStructured:YES];
    NSPortMessage * messageAlmostTooBig = [_messageHandler createDefaultGarbageDataMessageWithSize:1000 isArrayArrangementStructured:YES];
    
    XCTAssertFalse([_validationHandler isMessageValid:messageNonStructured]);
    XCTAssertTrue([_validationHandler isMessageValid:messageStructured]);
    XCTAssertFalse([_validationHandler isMessageValid:messageTooBig]);
    XCTAssertTrue([_validationHandler isMessageValid:messageAlmostTooBig]);
}

- (void)testDataManagerVacancy {
    NSPortMessage * messageNonStructured = [_messageHandler createDefaultStringMessage:@"test1" isArrayArrangementStructured:NO];
    NSPortMessage * messageStructured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    // These two messages are sent from the same message handler. Thus, their sender port is identical.
    XCTAssertTrue([_dataManager isStorageVacantForSender:messageNonStructured.sendPort]);
    XCTAssertTrue([_dataManager isStorageVacantForSender:messageStructured.sendPort]);
    
    // These are checked before accessing the data manager
    // For maintainability: These should also be checked in the data manager saveData method
    XCTAssertFalse([_validationHandler isMessageValid:messageNonStructured]);
    XCTAssertTrue([_validationHandler isMessageValid:messageStructured]);
    
    // Now we can add
    XCTAssertTrue([_dataManager saveDataFrom:messageStructured]);
    
    // Check that data was added
    XCTAssertFalse([_dataManager isStorageVacantForSender:messageStructured.sendPort]);
    XCTAssertFalse([_dataManager isStorageVacantForSender:messageNonStructured.sendPort]);
}

- (void) testDataHandlerExtractData{
    NSPortMessage * message1NonStructured = [_messageHandler createDefaultStringMessage:@"test1" isArrayArrangementStructured:NO];
    NSPortMessage * message1Structured = [_messageHandler createDefaultStringMessage:@"test1" isArrayArrangementStructured:YES];
    NSPortMessage * message2NonStructured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:NO];
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    NSPortMessage * message2StructuredCopy = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    NSData * message1NonStructuredData = [_messageHandler extractDataFrom:message1NonStructured];
    NSData * message1StructuredData = [_messageHandler extractDataFrom:message1Structured];
    NSData * message2NonStructuredData = [_messageHandler extractDataFrom:message2NonStructured];
    NSData * message2StructuredData = [_messageHandler extractDataFrom:message2Structured];
    NSData * message2StructuredDataCopy = [_messageHandler extractDataFrom:message2StructuredCopy];

    // Checking:
    // 1. Data after processing (extractData + save) is the same as data after extraction.
    // 2. Check 1 is maintained across message structure arrangements. The message handler should know how to extract data from message by examining the arrangement of the message, given in an enum inside the message.
    XCTAssertEqualObjects(message2StructuredData, message2StructuredDataCopy);
    XCTAssertEqualObjects(message2StructuredData, message2NonStructuredData);
    
    // Checking:
    // 1. Data remains unique.
    // 2. Check 1 is maintained across message structure arrangements.
    XCTAssertNotEqualObjects(message2StructuredData, message1NonStructuredData);
    XCTAssertNotEqualObjects(message2StructuredData, message1StructuredData);
}

- (void) testDataManagerGetData{
    // Data Manager saves data with message handler get extract data.
    // We can build on similar test to those in the testDataHandlerExtractData method.
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    // Message handler default messages are sent from the same port
    NSPort * senderPort = message2Structured.sendPort;
    
    NSData * message2StructuredData = [_messageHandler extractDataFrom:message2Structured];

    XCTAssertTrue([_dataManager saveDataFrom:message2Structured]);
    
    NSData * dataFromDataManager = [_dataManager getData:senderPort];
    
    XCTAssertEqualObjects(message2StructuredData, dataFromDataManager);
}


- (void) testDataManagerRemoveData{
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
     
    // Message handler default messages are sent from the same port
    NSPort * senderPort = message2Structured.sendPort;
    
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort]);
    XCTAssertTrue([_dataManager saveDataFrom:message2Structured]);
    XCTAssertFalse([_dataManager isStorageVacantForSender:senderPort]);
    
    [_dataManager removeSenderData:senderPort];
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort]);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

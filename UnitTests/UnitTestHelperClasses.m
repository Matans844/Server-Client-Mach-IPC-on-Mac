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

@interface UnitTestHelperClasses : XCTestCase

@property DataManager * dataManager;
@property MessageHandler * messageHandler;
@property ValidationHandler * validationHandler;

@end

// ------------------------------------ //
// So that we can test private methods

// ------------------------------------ //

@interface DataManager (Testing)
// "Private" properties
@property (atomic, retain, getter=getMessageManager) MessageHandler * messageManager;
@property (atomic, retain, getter=getDictSenderToHash) NSMutableDictionary<NSPort*, NSData*> * dictSenderToHash;
@property (atomic, retain, getter=getDictHashToData) NSMutableDictionary<NSData*, NSData*> * dictHashToData;
@property (atomic, retain, getter=getCounterOfDataHash) NSMutableDictionary<NSData*, NSNumber*> * counterOfDataHash;
// "Private" methods
- (BOOL) isStorageVacantForSender:(NSPort *)senderPort;
- (BOOL) isStorageVacantForHash:(NSData *)hashCode;
- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode;
- (void) addToDictHashToComponents:(NSData *)hashCode withData:(NSArray *)components;
- (void) initiateWith: (MessageHandler * _Nullable) messageManager;
- (NSData *) getHashCodeFromSender:(NSPort *) sender;
@end

// ------------------------------------ //

@interface MessageHandler (Testing)
// "Private" properties
@property (atomic, retain, getter=getDefaultPortNameSender) NSPort * defaultPortNameSender;
@property (atomic, retain, getter=getDefaultPortNameReceiver) NSPort * defaultPortNameReceiver;
// "Private" methods
- (NSPort * _Nullable) initiatePortWithString:(NSString *)serviceName;
- (NSData *) extractDataFromComponents:(NSArray *)messageComponents;
@end

// ------------------------------------ //

@implementation UnitTestHelperClasses

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


- (void) testDataManagerRemoveData1{
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
     
    // Message handler default messages are sent from the same port
    NSPort * senderPort = message2Structured.sendPort;
    
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort]);
    XCTAssertTrue([_dataManager saveDataFrom:message2Structured]);
    XCTAssertFalse([_dataManager isStorageVacantForSender:senderPort]);
    
    XCTAssertTrue([_dataManager removeSenderData:senderPort]);
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort]);
}

- (void) testDataManagerRemoveData2{
    NSPortMessage * message1Structured = [_messageHandler createStringMessage:@"test2" toPort:[_messageHandler getDefaultPortNameReceiver] fromPort:[_messageHandler getDefaultPortNameSender] isArrayArrangementStructured:YES];
    NSPortMessage * message2Structured = [_messageHandler createStringMessage:@"test2" toPort:[_messageHandler getDefaultPortNameReceiver] fromPort:[_messageHandler getDefaultPortNameReceiver] isArrayArrangementStructured:YES];
     
    // Both messages come from different ports
    NSPort * senderPort1 = message1Structured.sendPort;
    NSPort * senderPort2 = message2Structured.sendPort;
    XCTAssertNotEqualObjects(senderPort1, senderPort2);
    
    // Both messages arrive at the same port
    NSPort * receiverPort1 = message1Structured.receivePort;
    NSPort * receiverPort2 = message2Structured.receivePort;
    XCTAssertEqualObjects(receiverPort1, receiverPort2);
    
    // We should have room for both senders.
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort1]);
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort2]);
    
    // We are adding the first message.
    // We should still have room for the second message.
    XCTAssertTrue([_dataManager saveDataFrom:message1Structured]);
    XCTAssertFalse([_dataManager isStorageVacantForSender:senderPort1]);
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort2]);
    
    // We add the second message.
    XCTAssertTrue([_dataManager saveDataFrom:message2Structured]);
    
    // Are they both linked to the same data?
    XCTAssertEqualObjects([_dataManager getData:senderPort1], [_dataManager getData:senderPort2]);
    
    // We can delete the second message.
    // This does not affect the first message.
    XCTAssertTrue([_dataManager removeSenderData:senderPort2]);
    XCTAssertTrue([_dataManager isStorageVacantForSender:senderPort2]);
    XCTAssertFalse([_dataManager isStorageVacantForSender:senderPort1]);
    
    // The hash code is still present
    // NSData * hashCode = [[_dataManager getDictSenderToHash] objectForKey:senderPort1];
    NSData * hashCode = [_dataManager getHashCodeFromSender:senderPort1];
    
    // NSLog(@"hash code we want to find is: %@", hashCode);
    // NSLog(@"hash code for usual string: %@", [DataManager dataToSha256:[@"test2" dataUsingEncoding:NSUTF8StringEncoding]]);
    
    // XCTAssertTrue([DataManager dataToSha256:[@"test2" dataUsingEncoding:NSUTF8StringEncoding]] == hashCode);

    // XCTAssertEqualObjects([DataManager dataToSha256:[@"test2" dataUsingEncoding:NSUTF8StringEncoding]], hashCode);
    
    XCTAssertFalse([_dataManager isStorageVacantForHash:hashCode]);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

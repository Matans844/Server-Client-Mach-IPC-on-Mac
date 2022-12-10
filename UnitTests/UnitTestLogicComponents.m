//
//  UnitTestDatabase.m
//  UnitTestDatabase
//
//  Created by matan on 07/12/2022.
//

#import <XCTest/XCTest.h>
#import "definitions.h"
#import "DataManager.h"
#import "MessageHandler.h"
#import "ValidationHandler.h"
#import "PortHandler.h"
#import "NSMutableDictionaryWrapper.h"

@interface UnitTestLogicComponents : XCTestCase

@property DataManager * dataManagerForServer;
@property DataManager * dataManagerForClient;
@property MessageHandler * messageHandler;
@property ValidationHandler * validationHandler;

@end

// ------------------------------------ //
// Interface section from classes (through category):
// This allows us to test private properties and/or methods.

// ------------------------------------ //

@interface DataManager (Testing)

// "Private" properties
@property (atomic, assign, readonly, getter=getChosenCorrespondent) enum eRoleInCommunication chosenCorrespondent;
@property (atomic, retain, readonly, getter=getMessageManager) MessageHandler * messageHandler;
@property (atomic, retain, readonly, getter=getDictCorrespondentToHashWrapper) NSMutableDictionaryWrapper * dictCorrespondentToHash;
@property (atomic, retain, readonly, getter=getDictHashToDataWrapper) NSMutableDictionaryWrapper * dictHashToData;
@property (atomic, retain, readonly, getter=getCounterOfDataHashWrapper) NSMutableDictionaryWrapper * counterOfDataHash;
// "Private" methods
- (BOOL) isStorageVacantForCorrespondent:(NSPort *)chosenCorrespondent;
- (BOOL) isStorageVacantForHash:(NSData *)hashCode;
- (void) addToDictCorrespondentToHash:(NSPort *)chosenCorrespondent withHash:(NSData *)hashCode;
- (void) addToDictHashToData:(NSData *)hashCode withData:(NSData *)data;
- (void) addToCounterDataHash:(NSData *)hashCode;
- (NSData *) getHashCodeFromCorrespondent:(NSPort *)chosenCorrespondent;
- (NSString *) describeContent;
- (NSMutableDictionary<NSPort*, NSData*> *) getDictCorrespondentToHash;
- (NSMutableDictionary<NSData*, NSData*> *) getDictHashToData;
- (NSMutableDictionary<NSData*, NSNumber*> *) getCounterOfDataHash;
@end

// ------------------------------------ //

@interface MessageHandler (Testing)
// "Private" properties
@property (atomic, retain, readonly, getter=getDefaultPortNameSender) NSPort * defaultPortNameSender;
@property (atomic, retain, readonly, getter=getDefaultPortNameReceiver) NSPort * defaultPortNameReceiver;
@property (atomic, retain, readonly, getter=getPortHandler) PortHandler * portHandler;
// "Private" methods
- (NSData *) extractDataFromComponents:(NSArray *)messageComponents;
@end

// ------------------------------------ //

@implementation UnitTestLogicComponents

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    _validationHandler = [[ValidationHandler alloc] init];
    _messageHandler = [[MessageHandler alloc] init];
    _dataManagerForServer = [[DataManager alloc] initWithMessageHandler:_messageHandler chosenCorrespondent:server];
    _dataManagerForClient = [[DataManager alloc] initWithMessageHandler:_messageHandler chosenCorrespondent:client];    
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

- (void)testDataManagerVacancyForServer {
    NSPortMessage * messageNonStructured = [_messageHandler createDefaultStringMessage:@"test1" isArrayArrangementStructured:NO];
    NSPortMessage * messageStructured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    // These two messages are sent from the same message handler. Thus, their sender port is identical.
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:messageNonStructured.sendPort]);
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:messageStructured.sendPort]);
    
    // These are checked before accessing the data manager
    // For maintainability: These should also be checked in the data manager saveData method
    XCTAssertFalse([_validationHandler isMessageValid:messageNonStructured]);
    XCTAssertTrue([_validationHandler isMessageValid:messageStructured]);
    
    // Now we can add
    XCTAssertTrue([_dataManagerForServer saveDataFromMessage:messageStructured]);
    
    // Check that data was added
    XCTAssertFalse([_dataManagerForServer isStorageVacantForCorrespondent:messageStructured.sendPort]);
    XCTAssertFalse([_dataManagerForServer isStorageVacantForCorrespondent:messageNonStructured.sendPort]);
}

- (void)testDataManagerVacancyForClient {
    NSPortMessage * messageNonStructured = [_messageHandler createDefaultStringMessage:@"test1" isArrayArrangementStructured:NO];
    NSPortMessage * messageStructured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    // These two messages are sent from the same message handler. Thus, their sender port is identical.
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:messageNonStructured.receivePort]);
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:messageStructured.receivePort]);
    
    // These are checked before accessing the data manager
    // For maintainability: These should also be checked in the data manager saveData method
    XCTAssertFalse([_validationHandler isMessageValid:messageNonStructured]);
    XCTAssertTrue([_validationHandler isMessageValid:messageStructured]);
    
    // Now we can add
    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:messageStructured]);
    
    // Check that data was added
    XCTAssertFalse([_dataManagerForClient isStorageVacantForCorrespondent:messageStructured.receivePort]);
    XCTAssertFalse([_dataManagerForClient isStorageVacantForCorrespondent:messageNonStructured.receivePort]);
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

- (void) testDataManagerGetDataForServer{
    // Data Manager saves data with message handler get extract data.
    // We can build on similar test to those in the testDataHandlerExtractData method.
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    // Message handler default messages are sent from the same port
    NSPort * senderPort = message2Structured.sendPort;
    
    NSData * message2StructuredData = [_messageHandler extractDataFrom:message2Structured];

    XCTAssertTrue([_dataManagerForServer saveDataFromMessage:message2Structured]);
    
    NSData * dataFromDataManager = [_dataManagerForServer getDataByCorrespondent:senderPort];
    
    XCTAssertEqualObjects(message2StructuredData, dataFromDataManager);
}

- (void) testDataManagerGetDataForClient{
    // Data Manager saves data with message handler get extract data.
    // We can build on similar test to those in the testDataHandlerExtractData method.
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
    
    // Message handler default messages are sent from the same port
    NSPort * receiverPort = message2Structured.receivePort;
    
    NSData * message2StructuredData = [_messageHandler extractDataFrom:message2Structured];

    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:message2Structured]);
    
    NSData * dataFromDataManager = [_dataManagerForClient getDataByCorrespondent:receiverPort];
    
    XCTAssertEqualObjects(message2StructuredData, dataFromDataManager);
}


- (void) testDataManagerRemoveDataOneAdditionForServer{
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
     
    // Message handler default messages are sent from the same port
    NSPort * senderPort = message2Structured.sendPort;
    
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:senderPort]);
    XCTAssertTrue([_dataManagerForServer saveDataFromMessage:message2Structured]);
    XCTAssertFalse([_dataManagerForServer isStorageVacantForCorrespondent:senderPort]);
    
    XCTAssertTrue([_dataManagerForServer removeDataByCorrespondent:senderPort]);
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:senderPort]);
}

- (void) testDataManagerRemoveDataOneAdditionForClient{
    NSPortMessage * message2Structured = [_messageHandler createDefaultStringMessage:@"test2" isArrayArrangementStructured:YES];
     
    // Message handler default messages are sent from the same port
    NSPort * receiverPort = message2Structured.receivePort;
    
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort]);
    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:message2Structured]);
    XCTAssertFalse([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort]);
    
    XCTAssertTrue([_dataManagerForClient removeDataByCorrespondent:receiverPort]);
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort]);
}

- (void) testDataManagerRemoveDataMoreThanOneAdditionForServer{
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
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:senderPort1]);
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:senderPort2]);
    
    // We are adding the first message.
    // We should still have room for the second message.
    XCTAssertTrue([_dataManagerForServer saveDataFromMessage:message1Structured]);
    XCTAssertFalse([_dataManagerForServer isStorageVacantForCorrespondent:senderPort1]);
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:senderPort2]);
    
    // We add the second message.
    XCTAssertTrue([_dataManagerForServer saveDataFromMessage:message2Structured]);
    
    // Are they both linked to the same data?
    XCTAssertEqualObjects([_dataManagerForServer getDataByCorrespondent:senderPort1], [_dataManagerForServer getDataByCorrespondent:senderPort2]);
    
    // We can delete the second message.
    // This does not affect the first message.
    XCTAssertTrue([_dataManagerForServer removeDataByCorrespondent:senderPort2]);
    XCTAssertTrue([_dataManagerForServer isStorageVacantForCorrespondent:senderPort2]);
    XCTAssertFalse([_dataManagerForServer isStorageVacantForCorrespondent:senderPort1]);
    
    // The hash code is still present
    NSData * hashCode = [_dataManagerForServer getHashCodeFromCorrespondent:senderPort1];
    
    XCTAssertFalse([_dataManagerForServer isStorageVacantForHash:hashCode]);
}

- (void) testDataManagerRemoveDataMoreThanOneAdditionForClient{
    NSPortMessage * message1Structured = [_messageHandler createStringMessage:@"test2" toPort:[_messageHandler getDefaultPortNameSender] fromPort:[_messageHandler getDefaultPortNameReceiver] isArrayArrangementStructured:YES];
    NSPortMessage * message2Structured = [_messageHandler createStringMessage:@"test2" toPort:[_messageHandler getDefaultPortNameReceiver] fromPort:[_messageHandler getDefaultPortNameReceiver] isArrayArrangementStructured:YES];
     
    // Both messages come from the same port
    NSPort * senderPort1 = message1Structured.sendPort;
    NSPort * senderPort2 = message2Structured.sendPort;
    XCTAssertEqualObjects(senderPort1, senderPort2);
    
    // Both messages arrive at different ports
    NSPort * receiverPort1 = message1Structured.receivePort;
    NSPort * receiverPort2 = message2Structured.receivePort;
    XCTAssertNotEqualObjects(receiverPort1, receiverPort2);
    
    // We should have room for both receivers.
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort1]);
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort2]);
    
    // We are adding the first message.
    // We should still have room for the second message.
    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:message1Structured]);
    XCTAssertFalse([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort1]);
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort2]);
    
    // We add the second message.
    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:message2Structured]);
    
    // Are they both linked to the same data?
    XCTAssertEqualObjects([_dataManagerForClient getDataByCorrespondent:receiverPort1], [_dataManagerForClient getDataByCorrespondent:receiverPort2]);
    
    // We can delete the second message.
    // This does not affect the first message.
    XCTAssertTrue([_dataManagerForClient removeDataByCorrespondent:receiverPort2]);
    XCTAssertTrue([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort2]);
    XCTAssertFalse([_dataManagerForClient isStorageVacantForCorrespondent:receiverPort1]);
    
    // The hash code is still present
    NSData * hashCode = [_dataManagerForClient getHashCodeFromCorrespondent:receiverPort1];
    
    XCTAssertFalse([_dataManagerForClient isStorageVacantForHash:hashCode]);
}

- (void) testDataManagerDescriptionForClient{
    NSPortMessage * message1Structured = [_messageHandler createStringMessage:@"test2" toPort:[_messageHandler getDefaultPortNameSender] fromPort:[_messageHandler getDefaultPortNameReceiver] isArrayArrangementStructured:YES];
    NSPortMessage * message2Structured = [_messageHandler createStringMessage:@"test2" toPort:[_messageHandler getDefaultPortNameReceiver] fromPort:[_messageHandler getDefaultPortNameReceiver] isArrayArrangementStructured:YES];
    
    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:message1Structured]);
    XCTAssertTrue([_dataManagerForClient saveDataFromMessage:message2Structured]);
    
    NSLog(@"\n\n%@", [_dataManagerForClient description]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

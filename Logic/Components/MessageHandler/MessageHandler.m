//
//  MessageMaker.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "MessageHandler.h"
#import "PortHandler.h"

#define DEFAULT_SERVICE_NAME_SENDER @"org.matan.messagemaker.defaultsender"
#define DEFAULT_SERVICE_NAME_RECEIVER @"org.matan.messagemaker.defaultreceiver"

// ------------------------------------ //

@interface MessageHandler()

// "Private" properties
@property (atomic, retain, readonly, getter=getDefaultPortNameSender) NSPort * defaultPortNameSender;
@property (atomic, retain, readonly, getter=getDefaultPortNameReceiver) NSPort * defaultPortNameReceiver;

// Internal ad-hoc portHandler vs. Global portHandler for service?
// We have a unique port handler for objects of this class to support default messages.
// Default messages were mainly used in testing.
// Since this is an ad-hoc use case, I used an ad-hoc internal private portHandler.
@property (atomic, retain, readonly, getter=getPortHandler) PortHandler * portHandler;

// "Private" methods
- (NSData *) extractDataFromComponents:(NSArray *)messageComponents;

@end

// ------------------------------------ //


@implementation MessageHandler

- (id) init{
    self = [super init];
    if(self){
        PortHandler * localPortHandler = [[PortHandler alloc] init];
        self -> _portHandler = localPortHandler;
        self -> _defaultPortNameSender = [localPortHandler initiatePortWithString:DEFAULT_SERVICE_NAME_SENDER];
        self -> _defaultPortNameReceiver = [localPortHandler initiatePortWithString:DEFAULT_SERVICE_NAME_RECEIVER];
    }
    
    return self;
}

- (NSPortMessage *) createDefaultStringMessage:(NSString *)string isArrayArrangementStructured:(BOOL)isStructured{
    return [self createStringMessage:string toPort:[self getDefaultPortNameReceiver] fromPort:[self getDefaultPortNameSender] isArrayArrangementStructured:isStructured];
}

- (NSPortMessage *) createStringMessage:(NSString *)string toPort:(nonnull NSPort *)receiverPort fromPort:(nonnull NSPort *)senderPort isArrayArrangementStructured:(BOOL)isStructured{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // If the message is not structured, data is placed in the first cell of the components array.
    // If message is structured, we need to unparse the messsage according to the agreed arrangement.
    NSArray * array = isStructured ? [self encodeDataIntoCompositeStructureArray:data] : @[data];
    
    // This creates a new machPort
    // NSPort * senderPort = [NSMachPort port];
    
    return [self createMessageTo:receiverPort withArray:array fromPort:senderPort];
}

- (NSPortMessage *) createDefaultGarbageDataMessageWithSize:(NSUInteger)numberOfBytes isArrayArrangementStructured:(BOOL)isStructured{
    return [self createGarbageDataMessageWithSize:numberOfBytes toPort:[self getDefaultPortNameSender] fromPort:[self getDefaultPortNameSender] isArrayArrangementStructured:isStructured];
}

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes toPort:(nonnull NSPort *)receiverPort fromPort:(nonnull NSPort *)senderPort isArrayArrangementStructured:(BOOL)isStructured{
    void * bytes = malloc(numberOfBytes);
    NSData * data = [NSData dataWithBytes:bytes length:numberOfBytes];
    
    // Both data objects are entered into an array. The question is to which index.
    NSArray * array = isStructured ? [self encodeDataIntoCompositeStructureArray:data] : @[data];
    
    return [self createMessageTo:receiverPort withArray:array fromPort:senderPort];
}

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort withArray:(NSArray *)array fromPort:(NSPort *)senderPort{
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:senderPort receivePort:receiverPort components:array];
    
    return message;
}

- (NSArray *) encodeDataIntoCompositeStructureArray:(NSData *)data{
    NSMutableArray * mutableArray = [NSMutableArray arrayWithCapacity:DEFAULT_STRUCTURED_COMPONENT_SIZE];
    mutableArray[indexOfData] = data;
    mutableArray[indexOfRequestedFunctionality] = @"to_program_later_indicator_functionality_indicator";
    mutableArray[indexOfError] = @"to_program_later_indicator_error";
    mutableArray[indexOfComponentArrangementFlag] = [NSNumber numberWithInt:arrangedByStructuredArrangement];
    
    return [mutableArray copy];
}

- (NSData *) extractDataFrom:(NSPortMessage *)message{
    return [self extractDataFromComponents:message.components];
}

- (NSData *) extractDataFromComponents:(NSArray *)messageComponents{
    return [messageComponents objectAtIndex:indexOfData];
}

@end

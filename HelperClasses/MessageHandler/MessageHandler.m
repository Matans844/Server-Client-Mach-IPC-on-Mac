//
//  MessageMaker.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "MessageHandler.h"

#define DEFAULT_SERVICE_NAME_SENDER @"org.matan.messagemaker.defaultsender"
#define DEFAULT_SERVICE_NAME_RECEIVER @"org.matan.messagemaker.defaultreceiver"

// ------------------------------------ //

@interface MessageHandler()

// "Private" properties
@property (atomic, retain, getter=getDefaultPortNameSender) NSPort * defaultPortNameSender;
@property (atomic, retain, getter=getDefaultPortNameReceiver) NSPort * defaultPortNameReceiver;

// "Private" methods
- (NSPort * _Nullable) initiatePortWithString:(NSString *)serviceName;
- (NSData *) extractDataFromComponents:(NSArray *)messageComponents;
- (NSPort *) getPortByName:(NSString*) serviceName;

@end

// ------------------------------------ //


@implementation MessageHandler

- (id) init{
    self = [super init];
    if(self){
        self.defaultPortNameSender = [self initiatePortWithString:DEFAULT_SERVICE_NAME_SENDER];
        self.defaultPortNameReceiver = [self initiatePortWithString:DEFAULT_SERVICE_NAME_RECEIVER];
    }
    
    return self;
}

- (NSPort *)getPortByName:(NSString*) serviceName{
    return [[NSMachBootstrapServer sharedInstance] portForName:serviceName];
}

- (NSPort *) initiatePortWithString:(NSString *)serviceName{
    NSPort * result = [[NSMachBootstrapServer sharedInstance] servicePortWithName:serviceName];
    
    if(result == nil){
        // This probably means another instance is running
        NSLog(@"Unable to open server port for %@.", serviceName);
        // We copy the existing porty
        result = [self getPortByName:serviceName];
    }
    
    return result;
}

- (NSPortMessage *) createDefaultStringMessage:(NSString *)string isArrayArrangementStructured:(BOOL)isStructured{
    return [self createStringMessage:string toPort:[self getDefaultPortNameReceiver] fromPort:[self getDefaultPortNameSender] isArrayArrangementStructured:isStructured];
}

- (NSPortMessage *) createStringMessage:(NSString *) string toPort:(nonnull NSPort *)receiverPort fromPort:(nonnull NSPort *)senderPort isArrayArrangementStructured:(BOOL)isStructured{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // If the message is not structured, data is placed in the first cell of the components array.
    // If message is structured, we need to parse the messsage according to the agreed arrangement.
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
    NSArray * array = isStructured ? [self encodeDataIntoCompositeStructureArray:data] : @[data];
    // NSPort * senderPort = [NSMachPort port];
    
    return [self createMessageTo:receiverPort withArray:array fromPort:senderPort];
}

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort withArray:(NSArray *)array fromPort:(NSPort *)senderPort{
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:receiverPort receivePort:senderPort components:array];
    
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

//
//  MessageMaker.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "MessageHandler.h"

#define SERVICE_NAME @"org.matans.messagemaker"

// ------------------------------------ //

@interface MessageHandler()

// "Private" properties

// "Private" methods
- (void) initiate;
- (NSPort *)getSelfPort;
- (NSData *) extractDataFromComponents:(NSArray *)messageComponents;

@end

// ------------------------------------ //


@implementation MessageHandler

- (id) init{
    self = [super init];
    if(self){
        [self initiate];
    }
    
    return self;
}

- (NSPort *)getSelfPort{
    return [[NSMachBootstrapServer sharedInstance] portForName:SERVICE_NAME];
}

-(void) initiate{
    self.port = [[NSMachBootstrapServer sharedInstance] servicePortWithName:SERVICE_NAME];
    
    if (self.port == nil){
        // This probably means another instance is running
        NSLog(@"Unable to open server port.");
        
        return;
    }
}

- (NSPortMessage *) createStringMessage:(NSString *)string isArrayArrangementStructured:(BOOL)isStructured{
    return [self createStringMessage:string toPort:[self getSelfPort] isArrayArrangementStructured:isStructured];
}

- (NSPortMessage *) createStringMessage:(NSString *) string toPort:(nonnull NSPort *)receiverPort isArrayArrangementStructured:(BOOL)isStructured{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // If the message is not structured, data is placed in the first cell of the components array.
    // If message is structured, we need to parse the messsage according to the agreed arrangement.
    NSArray * array = isStructured ? [self parseDataIntoCompositeStructureArray:data] : @[data];
    
    NSPort * senderPort = [NSMachPort port];
    // NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    return [self createMessageTo:receiverPort withArray:array fromPort:senderPort];
}

- (NSArray *) parseDataIntoCompositeStructureArray:(NSData *)data{
    NSMutableArray * mutableArray = [NSMutableArray arrayWithCapacity:DEFAULT_STRUCTURED_COMPONENT_SIZE];
    mutableArray[indexOfData] = data;
    mutableArray[indexOfRequestedFunctionality] = @"to_program_later_indicator_functionality_indicator";
    mutableArray[indexOfError] = @"to_program_later_indicator_error";
    mutableArray[indexOfComponentArrangementFlag] = [NSNumber numberWithInt:arrangedByStructuredArrangement];
    
    return [mutableArray copy];
}

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes isArrayArrangementStructured:(BOOL)isStructured{
    return [self createGarbageDataMessageWithSize:numberOfBytes toPort:[self getSelfPort] isArrayArrangementStructured:isStructured];
}

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes toPort:(nonnull NSPort *)receiverPort isArrayArrangementStructured:(BOOL)isStructured{
    void * bytes = malloc(numberOfBytes);
    NSData * data = [NSData dataWithBytes:bytes length:numberOfBytes];
    NSArray * array = isStructured ? [self parseDataIntoCompositeStructureArray:data] : @[data];
    NSPort * senderPort = [NSMachPort port];
    // NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    return [self createMessageTo:receiverPort withArray:array fromPort:senderPort];
}

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort withArray:(NSArray *)array fromPort:(NSPort *)senderPort{
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:receiverPort receivePort:senderPort components:array];
    
    return message;
}

- (NSData *) extractDataFrom:(NSPortMessage *)message{
    // NSInteger indexOfData = [[NSNumber numberWithInt:indexOfData] intValue];
    return [self extractDataFromComponents:message.components];
}

- (NSData *) extractDataFromComponents:(NSArray *)messageComponents{
    return [messageComponents objectAtIndex:indexOfData];
}

@end

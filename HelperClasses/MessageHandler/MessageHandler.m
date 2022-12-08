//
//  MessageMaker.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "MessageHandler.h"
#import <malloc/malloc.h>

#define SERVICE_NAME @"org.matans.messagemaker"

typedef NS_ENUM(NSInteger,eMessageComponentCellType){
    data = 0,
    functionality = 1,
    error = 2,
};

typedef NS_ENUM(NSInteger, eMessageComponentArrangementType){
    composite = 0,
    nonComposite = 1,
};

// ------------------------------------ //

@interface MessageHandler()

// "Private" property
@property (atomic, retain, getter=getDictMessageComponentTypeToIndex) NSDictionary<NSNumber*, NSNumber*> * dictMessageComponentTypeToIndex;
@property (atomic, assign, getter=getMessageExtractionProtocol) enum eMessageComponentArrangementType messageArrangementType;

// "Private" methods
- (void) initiate;
- (NSPort *)getSelfPort;

@end

// ------------------------------------ //


@implementation MessageHandler

- (id) init{
    return [self initWithComponentDict:nil];
}

- (id) initWithComponentDict:(NSDictionary *) messageComponentDict{
    self = [super init];
    if(self){
        [self initiateWith:messageComponentDict];
    }
    
    return self;
}

- (NSPort *)getSelfPort
{
    return [[NSMachBootstrapServer sharedInstance] portForName:SERVICE_NAME];
}

-(void) initiateWith:(NSDictionary * _Nullable) messageComponentIndexDict
{
    self.port = [[NSMachBootstrapServer sharedInstance] servicePortWithName:SERVICE_NAME];
    
    if (self.port == nil){
        // This probably means another instance is running
        NSLog(@"Unable to open server port.");
        
        return;
    }
    
    if (messageComponentIndexDict){
        self.dictMessageComponentTypeToIndex = [[NSDictionary alloc] initWithDictionary:messageComponentIndexDict];
        self.messageArrangementType = composite;
    }
    else{
        self.dictMessageComponentTypeToIndex = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:data], 0, nil];
        self.messageArrangementType = nonComposite;
    }
}

- (NSPortMessage *) createStringMessage:(NSString *) string{
    return [self createStringMessage:string toPort:[self getSelfPort]];
}

- (NSPortMessage *) createStringMessage:(NSString *) string toPort:(nonnull NSPort *)sendToPort{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSPort * receivePort = [NSMachPort port];
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    return message;
}

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes{
    return [self createGarbageDataMessageWithSize:numberOfBytes toPort:[self getSelfPort]];
}

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes toPort:(nonnull NSPort *)sendToPort{
    void * bytes = malloc(numberOfBytes);
    NSData * data = [NSData dataWithBytes:bytes length:numberOfBytes];
    NSPort * receivePort = [NSMachPort port];
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    return message;
}

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort withData:(NSArray *)data fromPort:(NSPort *)senderPort{
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:receiverPort receivePort:senderPort components:data];
    
    return message;
}

-(NSData *) extractData:(NSPortMessage *)message{
    NSInteger indexOfData = [[[self getDictMessageComponentTypeToIndex] objectForKey:[NSNumber numberWithInt:data]] intValue];
    NSData * result = [message.components objectAtIndex:indexOfData];
    
    return result;
}

@end

//
//  MessageMaker.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "MessageMaker.h"
#import <malloc/malloc.h>

#define SERVICE_NAME @"org.matans.messagemaker"

// ------------------------------------ //

@interface MessageMaker()

// "Private" methods
- (void) initiate;

@end

// ------------------------------------ //


@implementation MessageMaker

- (NSPort *)getSelfPort
{
    return [[NSMachBootstrapServer sharedInstance] portForName:SERVICE_NAME];
}

-(void) initiate
{
    self.port = [[NSMachBootstrapServer sharedInstance] servicePortWithName:SERVICE_NAME];
    
    if (self.port == nil){
        // This probably means another instance is running
        NSLog(@"Unable to open server port.");
        
        return;
    }
}

- (id) init{
    self = [super init];
    if (self){
        [self initiate];
    }
    
    return self;
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

@end

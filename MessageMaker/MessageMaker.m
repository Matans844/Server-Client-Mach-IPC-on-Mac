//
//  MessageMaker.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "MessageMaker.h"
#import <malloc/malloc.h>

#define SERVICE_NAME @"org.matans.messagemaker"


@implementation MessageMaker

- (NSPort *)getServicePort
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

- (NSPortMessage *) createStringMessage:(NSString *) string{
    // NSString * testString = @"test";
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSPort * sendToPort = [self getServicePort];
    NSPort * receivePort = [NSMachPort port];
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    return message;
}

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes{
    void * bytes = malloc(numberOfBytes);
    NSData * data = [NSData dataWithBytes:bytes length:numberOfBytes];
    NSPort * sendToPort = [self getServicePort];
    NSPort * receivePort = [NSMachPort port];
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    return message;
}

@end

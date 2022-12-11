//
//  MachPortClient.m
//  MachPortsClient
//
//  Created by matan on 05/12/2022.
//

#import "MachPortsClient.h"

#define SERVICE_NAME @"org.matans.save"

@implementation MachPortsClient

- (NSPort *)getServicePort
{
    return [[NSMachBootstrapServer sharedInstance] portForName:SERVICE_NAME];
}

- (void) sendStringMessage:(NSString *)string
{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSPort * sendToPort = [self getServicePort];
    
    if (sendToPort == nil){
        NSLog(@"Unable to connect to service port");
        return;
    }
    
    // Client Server in IPC terminology are interchangeable and based on which service is sending data and which service is receiving data.
    
    // We will cretae a receiver port as well for this service
    NSPort * receivePort = [NSMachPort port];
    receivePort.delegate = self;
    
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:receivePort forMode:NSDefaultRunLoopMode];
    
    NSPortMessage * message = [[NSPortMessage alloc] initWithSendPort:sendToPort receivePort:receivePort components:@[data]];
    
    _responseReceived = NO;
    
    NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow: 5.0];
    if(![message sendBeforeDate:timeout]){
        NSLog(@"Send failed");
    }
    
    while (!_responseReceived) {
        [runLoop runUntilDate: [NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void) handlePortMessage:(NSPortMessage *)message
{
    _responseReceived = YES;
}

@end


//
//  MachServer.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachServer.h"

@implementation MachServer

- (void) initiateEventLoop{
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[self getSelfPort] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

- (void) handlePortMessage:(NSPortMessage *)message
{
    if(![[self getValidationHandler] isMessageValid:message]){
        NSLog(@"error");
        
        return;
    }
    
    eRequestedFunctionalityFromServer requestedFunc = [[self getMessageHandler] extractRequestedFunctionalityFrom:message];
    
    switch(requestedFunc){
        case saveData:
            [self save:message];
            break;
        case getData:
            [self send:message];
            break;
        case printStatus:
            [self printData];
            break;
        default:
            NSLog(@"error");
            break;
    }
}

- (void) save:(NSPortMessage *)message{
    [[self getDataManager] saveDataFromMessage:message];
}

- (void) send:(NSPortMessage *)message{
    NSData * requestedData = [[self getDataManager] getDataByCorrespondent:message.sendPort];
}




/*
NSPort * responsePort = message.sendPort;
if (responsePort != nil){
    // sender is still active
    NSArray * components = message.components;
    if (components.count > 0){
        NSString * data = [[NSString alloc] initWithData:components[0] encoding:NSUTF8StringEncoding];
        NSLog(@"Received data: \"%@\"", data);
    }
    
    NSPortMessage * response = [[NSPortMessage alloc] initWithSendPort:responsePort receivePort:nil components:message.components];
    response.msgid = message.msgid;
    NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
    [response sendBeforeDate:timeout];
    NSLog(@"Sent feedback response");
}
 */

@end

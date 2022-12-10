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
    eRequestStatus messageStatus = resultError;
    NSPortMessage * response = nil;
    id dataForResponse = nil;
    
    if(![[self getValidationHandler] isMessageValid:message]){
        NSLog(@"error\n");
        // TODO: We need to create a message saying this is bad response.
    }
    else{
        NSLog(@"Received message. Processing...\n");
        eRequestedFunctionalityFromServer requestedServerFunctionality = [[self getMessageHandler] extractRequestedFunctionalityFrom:message];

        switch(requestedServerFunctionality){
            case saveData:
                messageStatus = [self saveReceivedDataFrom:message];
                break;
            case getData:
                messageStatus = [self sendBackReceivedData:message requestedData:&dataForResponse];
                break;
            case printStatus:
                messageStatus = [self sendDescriptionOfData:&dataForResponse];
                break;
            default:
                NSLog(@"error");
                // TODO: Out of range error for the enum
                break;
        }
        
        response = [[self getMessageHandler] createMessageTo:message.sendPort withData:dataForResponse fromPort:[self getSelfPort] isArrayArrangementStructured:requestedServerFunctionality withFunctionality:requestedServerFunctionality withRequestResult:messageStatus];
    }
    
    [self sendResponseMessage:response originalMessage:message];
}

- (eRequestStatus) saveReceivedDataFrom:(NSPortMessage *)message {
    BOOL success = [[self getDataManager] saveDataFromMessage:message];
    
    return success ? resultNoError : resultError;
}

- (eRequestStatus) sendBackReceivedData:(NSPortMessage *)message requestedData:(NSData * _Nullable * _Nullable)dataForResponse{
    *dataForResponse = [[self getDataManager] getDataByCorrespondent:message.sendPort];
    
    return resultNoError;
}

- (void) sendResponseMessage:(NSPortMessage *)response originalMessage:(NSPortMessage *) message{
    response.msgid = message.msgid;
    NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
    [response sendBeforeDate:timeout];
    NSLog(@"Sent feedback response");
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

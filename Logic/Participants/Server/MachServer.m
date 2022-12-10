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
                messageStatus = [self saveReceivedDataIn:message];
                break;
            case getData:
                messageStatus = [self sendBackReceivedDataFrom:message.sendPort requestedData:&dataForResponse];
                break;
            case removeData:
                messageStatus = [self removeReceivedDataFrom:message.sendPort];
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
    
    response.msgid = message.msgid;
    [self sendResponseMessage:response];
}

- (eRequestStatus) saveReceivedDataIn:(NSPortMessage *)message {
    BOOL success = [[self getDataManager] saveDataFromMessage:message];
    
    return success ? resultNoError : resultError;
}

- (eRequestStatus) sendBackReceivedDataFrom:(NSPort *)clientSender requestedData:(NSData * _Nullable * _Nullable)dataForResponse{
    *dataForResponse = [[self getDataManager] getDataByCorrespondent:clientSender];
    
    return resultNoError;
}

- (eRequestStatus) removeReceivedDataFrom:(NSPort *)clientSender{
    BOOL success = [[self getDataManager] removeDataByCorrespondent:clientSender];
    
    return success ? resultNoError : resultError;
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

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

- (void) handlePortMessage:(NSPortMessage *)message{
    eRequestStatus requestStatus = resultError;
    NSPortMessage * response = nil;
    id dataForResponse = nil;
    
    if(![[self getValidationHandler] isMessageValid:message]){
        
        NSLog(@"error\n");
        // TODO: In the meantime, I can create a message saying it is bad response, but I need to follow up on this.
        
        response = [[self getMessageHandler] createMessageTo:message.sendPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverNothing withRequestResult:requestStatus];
        
        exit(ERROR_CODE_TO_DO);
    }
    else{
        // Only relevant if message is valid.
        NSLog(@"Received message. Processing...\n");
        eRequestedFunctionalityFromServer requestedServerFunctionality = [[self getMessageHandler] extractRequestedFunctionalityFrom:message];

        switch(requestedServerFunctionality){
            case serverNothing:
                
                NSLog(@"error\n");
                // TODO: Error Handler
                exit(ERROR_CODE_TO_DO);
                
                break;
                
            case serverSaveData:
                requestStatus = [self saveReceivedDataIn:message];
                break;
            case serverGetData:
                requestStatus = [self sendBackReceivedDataFrom:message.sendPort requestedData:&dataForResponse];
                break;
            case serverRemoveData:
                requestStatus = [self removeDataByChosenCorrespondent:message.sendPort];
                break;
            case serverPrintStatus:
                requestStatus = [self sendDescriptionOfData:&dataForResponse];
                break;
            default:
                
                NSLog(@"error\n");
                // TODO: Out of range error for enum
                exit(ERROR_CODE_TO_DO);
                
                break;
        }
        
        response = [[self getMessageHandler] createMessageTo:message.sendPort withData:dataForResponse fromPort:[self getSelfPort] isArrayArrangementStructured:requestedServerFunctionality withFunctionality:requestedServerFunctionality withRequestResult:requestStatus];
    }
    
    response.msgid = message.msgid;
    [self sendPreparedMessage:response];
}

- (eRequestStatus) saveReceivedDataIn:(NSPortMessage *)message {
    BOOL success = [[self getDataManager] saveDataFromMessage:message];
    
    return success ? resultNoError : resultError;
}

- (eRequestStatus) sendBackReceivedDataFrom:(NSPort *)clientSender requestedData:(NSData * _Nullable * _Nullable)dataForResponse{
    *dataForResponse = [[self getDataManager] getDataByCorrespondent:clientSender];
    
    return resultNoError;
}

@end

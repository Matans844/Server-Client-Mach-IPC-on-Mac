//
//  MachServer.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachServer.h"

@implementation MachServer

- (id) init{
    self = [super initWithCorrespondentType:serverSide];
    if(self){
        [self getSelfPort].delegate = self;
    }
    
    return self;
}

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
        
        [ErrorHandler exitProgramOnError];
        // TODO: In the meantime, I can create a message saying it is bad response, but then I need to add another enum value to both client and server functionalities.
        // response = [[self getMessageHandler] createMessageTo:message.sendPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverNothing withRequestResult:requestStatus];
        
    }
    else{
        // Only relevant if message is valid.
        NSLog(@"Received message. Processing...\n");
        eRequestedFunctionalityFromServer requestedServerFunctionality = [[self getMessageHandler] extractRequestedFunctionalityFrom:message];

        switch(requestedServerFunctionality){
            case serverSaveData:
                requestStatus = [self clientRequestSaveData:message];
                break;
            case serverGetData:
                requestStatus = [self clientRequestGetData:message requestedData:&dataForResponse];
                break;
            case serverRemoveData:
                requestStatus = [self clientRequestRemoveData:message];
                break;
            case serverPrintStatus:
                requestStatus = [self clientRequestPrintSelfData];
                break;
            default:
                [ErrorHandler exitProgramOnError];
                // break;
        }
        
        response = [[self getMessageHandler] createMessageTo:message.sendPort withData:dataForResponse fromPort:[self getSelfPort] isArrayArrangementStructured:requestedServerFunctionality withFunctionality:requestedServerFunctionality withRequestResult:requestStatus];
    }
    
    response.msgid = message.msgid;
    [self sendPreparedMessage:response withBlock:nil andRunLoop:nil];
}

- (eRequestStatus) clientRequestSaveData:(NSPortMessage *)message {
    BOOL success = [[self getDataManager] saveDataFromMessage:message];
    
    return success ? resultNoError : resultError;
}

- (eRequestStatus) clientRequestGetData:(NSPortMessage *)message requestedData:(NSData * _Nullable * _Nullable)dataForResponse{
    *dataForResponse = [[self getDataManager] getDataByCorrespondent:message.sendPort];
    
    return resultNoError;
}

- (eRequestStatus) clientRequestRemoveData:(NSPortMessage *)message{
    return [self removeDataByChosenCorrespondent:message.sendPort];
}

- (eRequestStatus) clientRequestPrintSelfData{
    NSLog(@"%@", [self description]);
    
    return resultNoError;
}

@end

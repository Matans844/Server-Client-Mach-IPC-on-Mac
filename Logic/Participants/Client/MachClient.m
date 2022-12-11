//
//  MachClient.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachClient.h"

// ------------------------------------ //

@interface MachClient()

// "Private" properties

// "Private" methods
- (eRequestStatus) sendPreparedMessageAndGetStatus:(NSPortMessage *)preparedMessage;
- (BOOL) compareData:(NSData *)receivedData otherData:(NSData *)originalData;

@end

// ------------------------------------ //

@implementation MachClient

- (id) init{
    self = [super initWithCorrespondentType:clientSide];
    if(self){
        responseReceived = NO;
        [self getSelfPort].delegate = self;
    }
    
    return self;
}

- (void) handlePortMessage:(NSPortMessage *)message{
    responseReceived = YES;
    [self setLastMessagedReceived:message];
}

- (eRequestStatus) sendPreparedMessageAndGetStatus:(NSPortMessage *)preparedMessage{
    [self sendPreparedMessage:preparedMessage withBlock:&responseReceived andRunLoop:[self createRunLoopWithPortToListen:[self getSelfPort]]];
    NSPortMessage * receivedMessage = [self getLastMessageReceived];
    
    eRequestStatus requestStatus = [[self getMessageHandler] extractRequestStatusFrom:receivedMessage];
    
    if(requestStatus != resultNoError){
        [ErrorHandler exitProgramOnError];
    }
    
    return requestStatus;
}

- (eRequestStatus) sendRequestToSaveDataAt:(NSPort *)serverPort withData:(NSData *)messageData{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:messageData fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverSaveData withRequestResult:initRequest];
    
    // Saving data in self data manager before sending so that we can compare later
    if(![[self getDataManager] saveDataFromMessage:requestToServer]){
        [ErrorHandler exitProgramOnError];
    }
    
    return [self sendPreparedMessageAndGetStatus:requestToServer];

}

- (NSData *) sendRequestToGetDataSavedAt:(NSPort *)serverPort{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverGetData withRequestResult:initRequest];
    
    [self sendPreparedMessageAndGetStatus:requestToServer];
    
    // If we get here, everything was successful (errors are checked in the function above)
    NSData * dataRecievedFromServer = [[self getMessageHandler] extractDataFrom:[self getLastMessageReceived]];
    
    return dataRecievedFromServer;
}

- (eRequestStatus) sendRequestToRemoveSavedDataAt:(NSPort *)serverPort{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverRemoveData withRequestResult:initRequest];

    return [self sendPreparedMessageAndGetStatus:requestToServer];
}

- (eRequestStatus) sendRequestServerPrintData:(NSPort *)serverPort{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverPrintStatus withRequestResult:initRequest];
    
    return [self sendPreparedMessageAndGetStatus:requestToServer];
}

- (NSPort *) findServerByName:(NSString *)serverName{
    return [[self getPortHandler] getPortByName:serverName];
}

- (BOOL) checkDataAtServer:(NSPort *)serverPort{
    NSData * receivedData = [self sendRequestToGetDataSavedAt:serverPort];
    NSData * originalData = [[self getDataManager] getDataByCorrespondent:serverPort];
    
    return [self compareData:receivedData otherData:originalData];
}

- (BOOL) compareData:(NSData *)receivedData otherData:(NSData *)originalData{
    return [originalData isEqual:receivedData];
}

- (eRequestStatus) printSelfData{
    NSLog(@"%@", [self description]);
    
    return resultNoError;
}

- (eRequestStatus) removeDataSentTo:(NSString *)serverName{
    return [self removeDataByChosenCorrespondent:[self findServerByName:serverName]];
}

@end


/*
- (void) handlePortMessage:(NSPortMessage *)message{
    eRequestStatus messageStatusFromeServer = (eRequestStatus) [[self getMessageHandler] extractDataFrom:message withIndexCellType:indexOfRequestResult];
    eRequestStatus requestStatus = resultError;
    NSData * receivedData = [[self getMessageHandler] extractDataFrom:message];

    if (messageStatusFromeServer != resultNoError){
        
        NSLog(@"error\n");
        // TODO: Define Error type
        exit(ERROR_CODE_TO_DO);
        
    }
    else if(![[self getValidationHandler] isMessageValid:message]){
        
        NSLog(@"error\n");
        // TODO: Define Error type
        exit(ERROR_CODE_TO_DO);
        
    }
    else{
        // Only relevant if message is valid.
        eRequestedFunctionalityFromServer requestedServerFunctionality = [[self getMessageHandler] extractRequestedFunctionalityFrom:message];
        
        // The encoding of the two functionality enums allows us to successfully cast:
        // User requests for client functionality that invoke messaging to the server for server functionality have the same encoding.
        eServerDependentClientFunctionality userRequestedServerDependentClientFunctionality = (eServerDependentClientFunctionality) requestedServerFunctionality;
    }
    
    if(requestStatus != resultNoError){
        NSLog(@"Received feedback... Operation unsuccessful\n");
    }
    else{
        NSLog(@"Received feedback... Operation successful\n");
    }
    //TODO: Use a dictionary to translate the eServerDependentClientFunctionality userRequestedServerDependentClientFunctionality enum to print a more informative message - The actual completed operation.
    
}
 */

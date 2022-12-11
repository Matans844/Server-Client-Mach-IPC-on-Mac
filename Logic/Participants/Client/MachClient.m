//
//  MachClient.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachClient.h"

@implementation MachClient

- (void) sendRequestToSaveDataAt:(NSPort *)serverPort withData:(NSData *)messageData{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:messageData fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverSaveData withRequestResult:initRequest];
    
    BOOL isOutgoingDataSavedAtClient = [[self getDataManager] saveDataFromMessage:requestToServer];
    
    if(!isOutgoingDataSavedAtClient){
        
        NSLog(@"error\n");
        // TODO: Define Error type
        exit(ERROR_CODE_TO_DO);
        
    }
    
    [self sendPreparedMessage:requestToServer];
}

- (void) sendRequestToRemoveSavedDataAt:(NSPort *)serverPort{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverRemoveData withRequestResult:initRequest];
    
    [self sendPreparedMessage:requestToServer];
}

- (void) sendRequestToReceiveDataSavedAt:(NSPort *)serverPort{
    NSPortMessage * requestToServer = [[self getMessageHandler] createMessageTo:serverPort withData:nil fromPort:[self getSelfPort] isArrayArrangementStructured:YES withFunctionality:serverGetData withRequestResult:initRequest];
    
    [self sendPreparedMessage:requestToServer];
    
}

- (BOOL) compareData:(NSData *)receivedData otherData:(NSData *)originalData{
    return [originalData isEqual:receivedData];
}

- (NSPort *) findServerByName:(NSString *)serverName{
    return [[self getPortHandler] getPortByName:serverName];
}


- (void) executeUserRequestedFunctionalityBeforeServer:(eUserChosenFunctionalityFromClient)chosenClientFunctionality{
    switch(chosenClientFunctionality){
        case clientNothing:
            break;
        case tellServerSaveData:
            break;
        case tellServerGetData:
            break;
        case tellServerRemoveData:
            break;
        case tellServerPrintStatus:
            break;
        case clientFindServer:
            break;
        case clientCheckData:
            break;
        case clientPrintStatus:
            break;
        case clientRemoveData:
            break;
        default:
            
            NSLog(@"error\n");
            // TODO: Out of range error for enum
            exit(ERROR_CODE_TO_DO);
            
            break;
    }
}

- (void) handlePortMessage:(NSPortMessage *)message{
    eRequestStatus messageStatus = (eRequestStatus) [[self getMessageHandler] extractDataFrom:message withIndexCellType:indexOfRequestResult];
    eRequestStatus requestStatus = resultError;

    if (messageStatus != resultNoError){
        
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
        NSLog(@"Received confirmation...\n");
        eRequestedFunctionalityFromServer requestedServerFunctionality = [[self getMessageHandler] extractRequestedFunctionalityFrom:message];
        
        // The encoding of the enums for functionality allows us to do this
        // User requests for client functionality that invoke messaging to the server for server functionality have the same encoding.
        eServerDependentClientFunctionality userRequestedServerDependentClientFunctionality = (eServerDependentClientFunctionality) requestedServerFunctionality;
        
        switch(userRequestedServerDependentClientFunctionality){
            case toldServerSaveData:
                [self verifyServerSavedData:message];
                break;
            case toldServerGetData:
                requestStatus = [self verifyServerGotData:message];
                break;
            case toldServerRemoveData:
                requestStatus = resultNoError;
            case toldServer
        }
    }
}

- (eRequestStatus) verifyServerGotData:(NSPortMessage *)receivedMessage{
    NSData * receivedData = [[self getMessageHandler] extractDataFrom:receivedMessage];
    NSData * originalData = [[self getDataManager] getDataByCorrespondent:receivedMessage.sendPort];
    eRequestStatus result = [self compareData:receivedData otherData:originalData] ? resultNoError : resultError;
    
    return result;
}

- (void) verifyServerSavedData:(NSPortMessage *)receivedMessage{
    [self sendRequestToReceiveDataSavedAt:receivedMessage.sendPort];
}

@end

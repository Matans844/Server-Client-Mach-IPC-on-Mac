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
- (eRequestStatus) verifyServerGotData:(NSPortMessage *)receivedMessage;
- (void) verifyServerSavedData:(NSPortMessage *)message;

@end

// ------------------------------------ //

@implementation MachClient


- (id) init{
    self = [super initWithCorrespondentType:clientSide];
    if(self){
        [self getSelfPort].delegate = self;
    }
    
    return self;
}


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
        
        // Sanity check for the two main requirements in the project.
        if(userRequestedServerDependentClientFunctionality == tellServerGetData){
            requestStatus = [self verifyServerGotData:message];
        }
        else if(userRequestedServerDependentClientFunctionality == tellServerSaveData){
            /*
             This is a bit tricky and not stable:
             We ask to send another message to the server.
             We should get a response message from the server with the data.
             This means we enter this handler again, but only now we use the more stable verifier ([self verifyServerGotData])
             This method compares the data received from the server with the data we have in our data manager.
             We know this works if and only if we see the handler printed two Operation succcessful messages
             */
            [self verifyServerSavedData:message];
        }
        else{
            requestStatus = resultNoError;
        }
    }
    
    if(requestStatus != resultNoError){
        NSLog(@"Received feedback... Operation unsuccessful\n");
    }
    else{
        NSLog(@"Received feedback... Operation successful\n");
    }
    //TODO: Use a dictionary to translate the eServerDependentClientFunctionality userRequestedServerDependentClientFunctionality enum to print a more informative message - The actual completed operation.
    
}

- (eRequestStatus) verifyServerGotData:(NSPortMessage *)receivedMessage{
    NSData * receivedData = [[self getMessageHandler] extractDataFrom:receivedMessage];
    NSData * originalData = [[self getDataManager] getDataByCorrespondent:receivedMessage.sendPort];
    eRequestStatus result = [self compareData:receivedData otherData:originalData] ? resultNoError : resultError;
    
    return result;
}

- (void) verifyServerSavedData:(NSPortMessage *)message{
    [self sendRequestToReceiveDataSavedAt:message.sendPort];
}

@end

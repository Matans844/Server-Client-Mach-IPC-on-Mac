//
//  MachClientUI.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachClientUI.h"

@implementation MachClientUI

- (id) initWithClientLogicObject:(MachClient *)clientInstance{
    self = [super init];
    if(self){
        self->_clientObject = [[MachClient alloc] initWithCorrespondentType:clientSide];
    }
    
    return self;
}

- (void) exampleSaveData{
    NSPort * serverPort = [[self getClient] findServerByName:DEFAULT_SERVER_SERVICE_NAME];
    NSData * dataForMessage = [[[[self getClient] getDataManager] getEncodingHandler] encodeStringToData:@"test1"];
    [[self getClient] sendRequestToSaveDataAt:serverPort withData:dataForMessage];
}

- (void) exampleGetData{
    NSPort * serverPort = [[self getClient] findServerByName:DEFAULT_SERVER_SERVICE_NAME];
    [[self getClient] sendRequestToGetDataSavedAt:serverPort];
}

- (void) exampleVerifyData{
    
}

/*
- (void) dispatcherExample:(eUserChosenFunctionalityFromClient)chosenClientFunctionality{
    switch(chosenClientFunctionality){
        case clientNothing:
            
            // Nothing to do here
            NSLog(@"error\n");
            // TODO: This is a very ad-hoc UI implementation... This clause should not be accessible in a proper console UI.
            exit(ERROR_CODE_TO_DO);
            
            break;
        case tellServerSaveData:
            NSPort * serverPort = [[self getClient] findServerByName:DEFAULT_SERVER_SERVICE_NAME];
            [[self getClient] sendRequestToSaveDataAt:serverPort withData:@"test1"];
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
            // TODO: ad-hoc console UI.
            exit(ERROR_CODE_TO_DO);
            
            break;
    }
}
 */

@end

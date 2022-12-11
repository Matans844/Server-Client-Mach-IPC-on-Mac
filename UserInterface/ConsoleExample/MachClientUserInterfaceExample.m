//
//  MachClientUI.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachClientUserInterfaceExample.h"

@implementation MachClientUserInterfaceExample

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

@end

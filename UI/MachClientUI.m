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
        
    }
    
    return self;
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

@end

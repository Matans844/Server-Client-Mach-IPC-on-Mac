//
//  Service.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "Correspondent.h"

// ------------------------------------ //

@interface Correspondent()

// "Private" properties

// "Private" methods

@end

// ------------------------------------ //

@implementation Correspondent

static NSNumber * _numberOfServerInstancesCreated = @(START_OF_INSTANCES_COUNT);
static NSNumber * _numberOfClientInstancesCreated = @(START_OF_INSTANCES_COUNT);

+ (void) setNumberOfServerInstancesCreated:(NSNumber *)newNumberOfInstances{
    _numberOfServerInstancesCreated = newNumberOfInstances;
}

+ (void) setNumberOfClientInstancesCreated:(NSNumber *)newNumberOfInstances{
    _numberOfClientInstancesCreated = newNumberOfInstances;
}

+ (NSNumber *) numberOfServerInstancesCreated{
    return _numberOfClientInstancesCreated;
}

+ (NSNumber *) numberOfClientInstancesCreated{
    return _numberOfServerInstancesCreated;
}

- (id) initWithCorrespondentType:(eRoleInCommunication)keyCorrespondent withPortDelegate:(id<NSPortDelegate> _Nullable __strong) delegateObject{
    self = [super init];
    if(self){
        NSString * baseServiceName;
        NSString * instanceIdentifier;
        NSNumber * newNumberOfInstances;
        
        switch(keyCorrespondent){
            case serverSide:
                baseServiceName = SERVER_SERVICE_BASE_NAME;
                instanceIdentifier = [[Correspondent numberOfServerInstancesCreated] stringValue];
                // update class property
                newNumberOfInstances = @([_numberOfServerInstancesCreated intValue] + 1);
                [Correspondent setNumberOfServerInstancesCreated:newNumberOfInstances];
                break;
            case clientSide:
                baseServiceName = CLIENT_SERVICE_BASE_NAME;
                instanceIdentifier = [[Correspondent numberOfClientInstancesCreated] stringValue];
                // update class property
                newNumberOfInstances = @([_numberOfClientInstancesCreated intValue] + 1);
                [Correspondent setNumberOfClientInstancesCreated:newNumberOfInstances];
                break;
            default:
                
                NSLog(@"error\n");
                // TODO: Out of range error for the enum
                exit(ERROR_CODE_TO_DO);
                
                break;
        }
        
        NSString * newServiceName = [NSString stringWithFormat:@"%@%@", baseServiceName, instanceIdentifier];
        self->_serviceName = newServiceName;
        
        PortHandler * localPortHandler = [[PortHandler alloc] init];
        self -> _portHandler = localPortHandler;
        NSPort * servicePort = [localPortHandler initiatePortWithString:newServiceName];
        servicePort.delegate = delegateObject;
        self->_port = servicePort;

        self->_validationHandler = [[ValidationHandler alloc] init];
        self->_messageHandler = [[MessageHandler alloc] init];
        self->_dataManager = [[DataManager alloc] initWithMessageHandler:_messageHandler chosenCorrespondent:keyCorrespondent];
    }
    
    return self;
}

- (eRequestStatus) sendDescriptionOfData:(NSString * _Nullable * _Nullable)dataForResponse{
    NSString * dataManagerDescription = [NSString stringWithFormat:@"%@", [self getDataManager]];
    
    // FUTURE:
    // 1. We can add identifier here, defined in super class (Correspondent).
    // 2. We can transfer this mehtod into the super class.
    NSString * headline = [self getChosenCorrespondent] == serverSide ? @"Mach Server:\n" : @"Mach Client:\n";
    NSString * description = [NSString stringWithFormat:@"%@%@", headline, dataManagerDescription];
    
    *dataForResponse = description;
    
    return resultNoError;
}

- (void) sendPreparedMessage:(NSPortMessage *)filledMessage{
    // The message has all its fields filled.
    // Recipient is already there.
    NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:WAITING_PERIOD_FOR_MESSAGE_SENDING];
    if(![filledMessage sendBeforeDate:timeout]){
        
        NSLog(@"Send failed\n");
        //TODO: Error code
        exit(ERROR_CODE_TO_DO);

    }
}

- (eRequestStatus) removeDataByChosenCorrespondent:(NSPort *)keyCorrespondent{
    BOOL success = [[self getDataManager] removeDataByKeyCorrespondent:keyCorrespondent];
    
    return success ? resultNoError : resultError;
}

@end

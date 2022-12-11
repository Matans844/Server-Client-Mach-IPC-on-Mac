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

- (id) initWithCorrespondentType:(eRoleInCommunication)keyCorrespondent{
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
        self->_port = servicePort;

        self->_validationHandler = [[ValidationHandler alloc] init];
        self->_messageHandler = [[MessageHandler alloc] init];
        self->_dataManager = [[DataManager alloc] initWithMessageHandler:_messageHandler chosenCorrespondent:keyCorrespondent];
    }
    
    return self;
}

- (eRequestStatus) sendDescriptionOfData:(NSString * _Nullable * _Nullable)dataForResponse{
    *dataForResponse = [self description];
    
    return resultNoError;
}

- (NSString *) description{
    NSString * headline = [self getChosenCorrespondent] == serverSide ? @"Mach Server:\n" : @"Mach Client:\n";
    NSString * dataManagerDescription = [NSString stringWithFormat:@"%@", [self getDataManager]];
    
    return [NSString stringWithFormat:@"%@%@", headline, dataManagerDescription];
}

- (void) sendPreparedMessage:(NSPortMessage *)filledMessage withBlock:(BOOL * _Nullable)pointerToBlockFlag andRunLoop:(NSRunLoop * _Nullable)runLoop{
    // The message has all its fields filled.
    // Recipient is already there.
    NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:WAITING_PERIOD_FOR_MESSAGE_SENDING];
    if(![filledMessage sendBeforeDate:timeout]){
        [ErrorHandler exitProgramOnError];
    }
    
    if(pointerToBlockFlag){
        if(!runLoop){
            [ErrorHandler exitProgramOnError];
        }
        BOOL isBlocked = *pointerToBlockFlag;
        while (isBlocked){
            // [runLoop runUntilDate: [NSDate dateWithTimeIntervalSinceNow:0.1]];
            [runLoop runUntilDate: [NSDate dateWithTimeIntervalSinceNow:WAITING_PERIOD_FOR_BLOCKING_MESSAGE_SENDING]];
        }
    }
}

- (NSRunLoop *) createRunLoopWithPortToListen:(NSPort *)portToListen{
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:portToListen forMode:NSDefaultRunLoopMode];
    
    return runLoop;
}

- (eRequestStatus) removeDataByChosenCorrespondent:(NSPort *)keyCorrespondent{
    BOOL success = [[self getDataManager] removeDataByKeyCorrespondent:keyCorrespondent];
    
    return success ? resultNoError : resultError;
}

@end

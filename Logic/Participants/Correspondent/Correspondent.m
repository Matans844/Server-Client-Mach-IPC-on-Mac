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

static NSNumber * _numberOfInstancesCreated = @0;

+ (void) setNumberOfInstancesCreated:(NSNumber *)newNumberOfInstances{
    _numberOfInstancesCreated = newNumberOfInstances;
}

+ (NSNumber *) numberOfInstancesCreated{
    return _numberOfInstancesCreated;
}

- (id) initWithName:(NSString *)baseServiceName chosenCorrespondent:(enum eRoleInCommunication)keyCorrespondent withPortDelegate:(id<NSPortDelegate> _Nullable __strong) delegateObject{
    self = [super init];
    if(self){
        NSString * instanceIdentifier = [[Correspondent numberOfInstancesCreated] stringValue];
        
        PortHandler * localPortHandler = [[PortHandler alloc] init];
        self -> _portHandler = localPortHandler;
        
        NSString * newServiceName = [NSString stringWithFormat:@"%@%@", baseServiceName, instanceIdentifier];
        self->_serviceName = newServiceName;
        
        NSPort * servicePort = [localPortHandler initiatePortWithString:newServiceName];
        servicePort.delegate = delegateObject;
        self->_port = servicePort;
        
        self->_chosenCorrespondent = keyCorrespondent;
        self->_validationHandler = [[ValidationHandler alloc] init];
        self->_messageHandler = [[MessageHandler alloc] init];
        self->_dataManager = [[DataManager alloc] initWithMessageHandler:_messageHandler chosenCorrespondent:keyCorrespondent];
        
        // Update the class property
        NSNumber * newNumberOfInstances = @([_numberOfInstancesCreated intValue] + 1);
        [Correspondent setNumberOfInstancesCreated:newNumberOfInstances];
    }
    
    return self;
}

@end

//
//  Service.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>
#import "definitions.h"
#import "MessageHandler.h"
#import "DataManager.h"
#import "ValidationHandler.h"
#import "PortHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface Correspondent : NSObject

//Used to uniquely define correspondent name
@property (class) NSNumber * numberOfServerInstancesCreated;
@property (class) NSNumber * numberOfClientInstancesCreated;

@property (atomic, readonly, getter=getSelfServiceName) NSString * serviceName;
@property (atomic, readonly, getter=getSelfPort) NSPort * _Nullable port;

@property (atomic, readonly, getter=getChosenCorrespondent) enum eRoleInCommunication chosenCorrespondent;
@property (atomic, readonly, getter=getValidationHandler) ValidationHandler * validationHandler;
@property (atomic, readonly, getter=getMessageHandler) MessageHandler * messageHandler;
@property (atomic, readonly, getter=getDataManager) DataManager * dataManager;
@property (atomic, readonly, getter=getPortHandler) PortHandler * portHandler;

+ (void) setNumberOfServerInstancesCreated:(NSNumber *)newNumberOfInstances;
+ (NSNumber *) numberOfServerInstancesCreated;

+ (void) setNumberOfClientInstancesCreated:(NSNumber *)newNumberOfInstances;
+ (NSNumber *) numberOfClientInstancesCreated;
- (void) sendResponseMessage:(NSPortMessage *)response;

- (id) initWithName:(NSString *)baseServiceName chosenCorrespondent:(enum eRoleInCommunication)keyCorrespondent withPortDelegate:(id<NSPortDelegate> _Nullable __strong) delegateObject NS_DESIGNATED_INITIALIZER;
- (id) init NS_UNAVAILABLE;
- (eRequestStatus) sendDescriptionOfData:(NSString ** _Nullable)dataForResponse

@end

NS_ASSUME_NONNULL_END

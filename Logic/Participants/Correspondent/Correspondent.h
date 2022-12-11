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
@property (atomic, readonly, getter=getChosenCorrespondent) eRoleInCommunication chosenCorrespondent;
@property (atomic, readonly, getter=getValidationHandler) ValidationHandler * validationHandler;
@property (atomic, readonly, getter=getMessageHandler) MessageHandler * messageHandler;
@property (atomic, readonly, getter=getDataManager) DataManager * dataManager;
@property (atomic, readonly, getter=getPortHandler) PortHandler * portHandler;

+ (void) setNumberOfServerInstancesCreated:(NSNumber *)newNumberOfInstances;
+ (NSNumber *) numberOfServerInstancesCreated;
+ (void) setNumberOfClientInstancesCreated:(NSNumber *)newNumberOfInstances;
+ (NSNumber *) numberOfClientInstancesCreated;

// - (id) initWithCorrespondentType:(eRoleInCommunication)keyCorrespondent withPortDelegate:(id<NSPortDelegate> _Nullable __strong)delegateObject;
- (id) initWithCorrespondentType:(eRoleInCommunication)keyCorrespondent;

- (eRequestStatus) sendDescriptionOfData:(NSString * _Nullable * _Nullable)dataForResponse;
- (eRequestStatus) removeDataByChosenCorrespondent:(NSPort *)keyCorrespondent;
// - (void) sendPreparedMessage:(NSPortMessage *)filledMessage;
- (void) sendPreparedMessage:(NSPortMessage *)filledMessage withBlock:(BOOL * _Nullable)pointerToBlockFlag andRunLoop:(NSRunLoop * _Nullable)runLoop;
- (NSRunLoop *) createRunLoopWithPortToListen:(NSPort *)port;

@end

NS_ASSUME_NONNULL_END

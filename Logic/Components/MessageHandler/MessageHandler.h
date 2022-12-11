//
//  MessageMaker.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>
#import "definitions.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageHandler : NSObject<NSPortDelegate>

- (id) init;

- (NSPortMessage *) createDefaultStringMessage:(NSString *)string
                  isArrayArrangementStructured:(BOOL)isStructured
                             withFunctionality:(eRequestedFunctionalityFromServer)requestedFunction
                             withRequestResult:(eRequestStatus)requestStatus;

- (NSPortMessage *) createStringMessage:(NSString *)string
                                 toPort:(nonnull NSPort *)receiverPort
                               fromPort:(nonnull NSPort *)senderPort
           isArrayArrangementStructured:(BOOL)isStructured
                      withFunctionality:(eRequestedFunctionalityFromServer)requestedFunction
                      withRequestResult:(eRequestStatus)requestStatus;

- (NSPortMessage *) createDefaultGarbageDataMessageWithSize:(NSUInteger)numberOfBytes
                               isArrayArrangementStructured:(BOOL)isStructured
                                          withFunctionality:(eRequestedFunctionalityFromServer)requestedFunction
                                          withRequestResult:(eRequestStatus)requestStatus;

- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes
                                              toPort:(nonnull NSPort *)receiverPort
                                            fromPort:(nonnull NSPort *)senderPort
                        isArrayArrangementStructured:(BOOL)isStructured
                                   withFunctionality:(eRequestedFunctionalityFromServer)requestedFunction
                                   withRequestResult:(eRequestStatus)requestStatus;

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort
                           withData:(NSData * _Nullable)data
                           fromPort:(NSPort *)senderPort
       isArrayArrangementStructured:(BOOL)isStructured
                  withFunctionality:(eRequestedFunctionalityFromServer)requestedFunction
                  withRequestResult:(eRequestStatus)requestStatus;

- (NSData *) extractDataFrom:(NSPortMessage *)message;
- (NSData *) extractDataFrom:(NSPortMessage *)message
           withIndexCellType:(eMessageComponentCellType)indexOfType;
- (eRequestedFunctionalityFromServer) extractRequestedFunctionalityFrom:(NSPortMessage *)message;

@end

NS_ASSUME_NONNULL_END

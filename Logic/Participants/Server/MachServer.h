//
//  MachServer.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>
#import "Correspondent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MachServer : Correspondent<NSPortDelegate>

- (void) initiateEventLoop;
- (eRequestStatus) saveReceivedDataFrom:(NSPortMessage *)message;

- (eRequestStatus) sendBackReceivedData:(NSPortMessage *)message requestedData:(NSData * _Nullable * _Nullable)dataForResponse;
// - (eRequestStatus) sendBackReceivedData:(NSPortMessage *)message;

// - (eRequestStatus) sendDescriptionOfData;
//- (void) sendResponseMessage:(NSPortMessage *)message

- (void) sendResponseMessage:(NSPortMessage *)response originalMessage:(NSPortMessage *) message;


@end

NS_ASSUME_NONNULL_END

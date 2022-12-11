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
- (eRequestStatus) saveReceivedDataIn:(NSPortMessage *)message;
- (eRequestStatus) sendBackReceivedDataFrom:(NSPort *)clientSender requestedData:(NSData * _Nullable * _Nullable)dataForResponse;

@end

NS_ASSUME_NONNULL_END

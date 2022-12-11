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
- (eRequestStatus) clientRequestSaveData:(NSPortMessage *)message;
// - (eRequestStatus) clientRequestGetData:(NSPort *)clientSender requestedData:(NSData * _Nullable * _Nullable)dataForResponse;
- (eRequestStatus) clientRequestGetData:(NSPortMessage *)message requestedData:(NSData * _Nullable * _Nullable)dataForResponse;
- (eRequestStatus) clientRequestPrintSelfData;
- (eRequestStatus) clientRequestRemoveData:(NSPortMessage *)message;

@end

NS_ASSUME_NONNULL_END

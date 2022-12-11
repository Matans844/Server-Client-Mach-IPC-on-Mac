//
//  MachClient.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>
#import "Correspondent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MachClient : Correspondent<NSPortDelegate>

// Methods that require functionality that relies on messaging the server are blocking until response
{
    BOOL responseReceived;
}

// @property(atomic, readwrite) BOOL responseReceived;
@property(atomic, readwrite, getter=getLastMessageReceived, setter=setLastMessagedReceived:) NSPortMessage * lastMessageReceived;

- (eRequestStatus) sendRequestToSaveDataAt:(NSPort *)serverPort withData:(NSData *)messageData;
- (eRequestStatus) sendRequestToRemoveSavedDataAt:(NSPort *)serverPort;
- (eRequestStatus) sendRequestToReceiveDataSavedAt:(NSPort *)serverPort;
- (eRequestStatus) sendRequestServerPrintData:(NSPort *)serverPort;

- (eRequestStatus) printSelfData:(NSPort *)serverPort;
- (BOOL) compareData:(NSData *)receivedData otherData:(NSData *)originalData;
- (NSPort *) findServerByName:(NSString *)serverName;

@end

NS_ASSUME_NONNULL_END

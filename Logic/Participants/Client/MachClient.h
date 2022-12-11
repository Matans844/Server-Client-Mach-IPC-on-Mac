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

- (void) sendRequestToSaveDataAt:(NSPort *)serverPort withData:(NSData *)messageData;
- (void) sendRequestToRemoveSavedDataAt:(NSPort *)serverPort;
- (void) sendRequestToReceiveDataSavedAt:(NSPort *)serverPort;
- (BOOL) compareData:(NSData *)receivedData otherData:(NSData *)originalData;
- (NSPort *) findServerByName:(NSString *)serverName;

@end

NS_ASSUME_NONNULL_END

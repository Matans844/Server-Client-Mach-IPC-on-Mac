//
//  MachPortServer.h
//  MachPortsServer
//
//  Created by matan on 05/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MachPortsServer : NSObject<NSPortDelegate>

@property NSPort * port;

// NSMapTable should help with weak references to deactivated clients
@property NSMutableDictionary * dictSenderPortToMsgIDs;
@property NSMutableDictionary * dictMsgIDToMsg;
@property NSMutableDictionary * dictMsgDataHashToMsgID;

- (void) initiate;

@end

NS_ASSUME_NONNULL_END

//
//  Database.h
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import <Foundation/Foundation.h>
#import "MessageHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+ (NSData *) doSha256:(NSData *)dataIn;
+ (NSData *) encodeData:(NSData *)data;
+ (NSData *) encodeDataAndCalculateHash:(NSData *)messageData;

- (id) init;
- (id) initWithMessageManager:(MessageHandler * _Nullable)messageManager NS_DESIGNATED_INITIALIZER;

- (BOOL) saveDataFromMessage:(NSPortMessage *)message;
- (NSData * _Nullable) getDataBySender: (NSPort *)sender;
- (BOOL) removeDataBySender: (NSPort *)sender;

@end

NS_ASSUME_NONNULL_END

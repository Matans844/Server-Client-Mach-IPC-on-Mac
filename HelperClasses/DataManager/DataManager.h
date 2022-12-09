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

- (id) initWithMessageHandler:(MessageHandler * _Nullable)messageManager chosenCorrespondent:(enum eRoleInCommunication)keyCorrespondent NS_DESIGNATED_INITIALIZER;
- (id) init NS_UNAVAILABLE;

- (BOOL) saveDataFromMessage:(NSPortMessage *)message;
- (NSData * _Nullable) getDataByCorrespondent: (NSPort *)chosenCorrespondent;
- (BOOL) removeDataByCorrespondent: (NSPort *)chosenCorrespondent;

@end

NS_ASSUME_NONNULL_END

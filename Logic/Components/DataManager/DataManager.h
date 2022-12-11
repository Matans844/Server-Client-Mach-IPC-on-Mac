//
//  Database.h
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import <Foundation/Foundation.h>
#import "MessageHandler.h"
#import "EncodingHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

@property (atomic, readonly, getter=getEncodingHandler) EncodingHandler * encodingHandler;

- (id) initWithMessageHandler:(MessageHandler * _Nullable)messageManager
          chosenCorrespondent:(eRoleInCommunication)keyCorrespondent NS_DESIGNATED_INITIALIZER;
- (id) init NS_UNAVAILABLE;
- (BOOL) saveDataFromMessage:(NSPortMessage *)message;
- (NSData * _Nullable) getDataByCorrespondent: (NSPort *)chosenCorrespondent;
- (BOOL) removeDataByKeyCorrespondent: (NSPort *)chosenCorrespondent;

@end

NS_ASSUME_NONNULL_END

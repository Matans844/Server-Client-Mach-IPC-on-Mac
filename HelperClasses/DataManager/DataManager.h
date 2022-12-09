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

+ (NSData *) doSha256: (NSData *) dataIn;
+ (NSData *) dataToSha256: (NSData *) messageData;

- (id) initWithMessageManager: (MessageHandler * _Nullable) messageManager NS_DESIGNATED_INITIALIZER;
- (id) init;
- (BOOL) saveData: (NSPortMessage *) message;
- (NSArray * _Nullable) getComponent: (NSPort *) sender;
- (NSData * _Nullable) getData: (NSPort *) sender;
- (void) removeData: (NSPort *) sender;

@end

NS_ASSUME_NONNULL_END

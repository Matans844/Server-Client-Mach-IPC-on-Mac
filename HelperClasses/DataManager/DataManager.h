//
//  Database.h
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import <Foundation/Foundation.h>
#import "MessageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+ (NSData *) doSha256: (NSData *) dataIn;
+ (NSData *) dataToSha256: (NSData *) messageData;

- (id) init;
- (id) initWithMessageManager: (MessageManager * _Nullable) messageManager NS_DESIGNATED_INITIALIZER;
- (BOOL) saveData: (NSPortMessage *) message;
- (NSArray * _Nullable) getData: (NSPort *) sender;
- (void) removeData: (NSPort *) sender;

@end

NS_ASSUME_NONNULL_END

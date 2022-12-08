//
//  Database.h
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+ (NSData *) doSha256: (NSData *) dataIn;
+ (NSData *) machMessageToSha256: (NSPortMessage *) message;

// - (void) initiate;
- (id) init;


- (BOOL) saveData: (NSPortMessage *) message;
- (NSArray * _Nullable) getData: (NSPort *) sender;
- (void) removeData: (NSPort *) sender;

- (BOOL) isStorageVacant: (NSPort *) senderPort;
- (BOOL) isDataValid: (NSPortMessage *) message;

@end

NS_ASSUME_NONNULL_END

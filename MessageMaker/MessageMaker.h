//
//  MessageMaker.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageMaker : NSObject<NSPortDelegate>

@property NSPort * port;

- (void) initiate;
- (NSPortMessage *) createStringMessage: (NSString *) string;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes;

@end

NS_ASSUME_NONNULL_END

//
//  MessageMaker.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageManager : NSObject<NSPortDelegate>

@property NSPort * port;

- (id) init;
- (NSPortMessage *) createStringMessage: (NSString *) string;
- (NSPortMessage *) createStringMessage: (NSString *) string toPort:(NSPort *) sendToPort;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes toPort:(NSPort *) sendToPort;
- (NSPortMessage *) createReceiveDataMessage: (NSArray *) data toPort:(NSPort *) sendToPort;

@end

NS_ASSUME_NONNULL_END
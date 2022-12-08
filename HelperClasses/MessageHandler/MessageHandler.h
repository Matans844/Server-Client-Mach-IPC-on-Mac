//
//  MessageMaker.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MessageHandler : NSObject<NSPortDelegate>

@property NSPort * port;

- (id) init;
- (id) initWithComponentDict:(NSArray * _Nullable) messageComponentDict NS_DESIGNATED_INITIALIZER;
- (NSPortMessage *) createStringMessage: (NSString *) string;
- (NSPortMessage *) createStringMessage: (NSString *) string toPort:(NSPort *) sendToPort;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes toPort:(NSPort *) sendToPort;
- (NSPortMessage *) createMessageTo:(NSPort *)sendToPort withData:(NSArray *) data fromPort:(NSPort *)senderPort;
- (NSData *) extractDataFrom:(NSPortMessage *)message;

@end

NS_ASSUME_NONNULL_END

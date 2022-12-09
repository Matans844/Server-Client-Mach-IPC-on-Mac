//
//  MessageMaker.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>
#import "definitions.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageHandler : NSObject<NSPortDelegate>

- (id) init;
- (NSPortMessage *) createDefaultStringMessage: (NSString *) string isArrayArrangementStructured:(BOOL) isStructured;
// - (NSPortMessage *) createStringMessage: (NSString *) string toPort:(NSPort *) receiverPort isArrayArrangementStructured:(BOOL) isStructured;
- (NSPortMessage *) createStringMessage:(NSString *) string toPort:(nonnull NSPort *)receiverPort fromPort:(nonnull NSPort *)senderPort isArrayArrangementStructured:(BOOL)isStructured;

- (NSPortMessage *) createDefaultGarbageDataMessageWithSize: (NSUInteger) numberOfBytes isArrayArrangementStructured:(BOOL) isStructured;
// - (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes toPort:(NSPort *) receiverPort isArrayArrangementStructured:(BOOL) isStructured;
- (NSPortMessage *) createGarbageDataMessageWithSize:(NSUInteger)numberOfBytes toPort:(nonnull NSPort *)receiverPort fromPort:(nonnull NSPort *)senderPort isArrayArrangementStructured:(BOOL)isStructured

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort withArray:(NSArray *)array fromPort:(NSPort *)senderPort;
- (NSData *) extractDataFrom:(NSPortMessage *)message;

@end

NS_ASSUME_NONNULL_END

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
- (NSPortMessage *) createStringMessage: (NSString *) string isArrayArrangementStructured:(BOOL) isStructured;
- (NSPortMessage *) createStringMessage: (NSString *) string toPort:(NSPort *) receiverPort isArrayArrangementStructured:(BOOL) isStructured;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes isArrayArrangementStructured:(BOOL) isStructured;
- (NSPortMessage *) createGarbageDataMessageWithSize: (NSUInteger) numberOfBytes toPort:(NSPort *) receiverPort isArrayArrangementStructured:(BOOL) isStructured;

- (NSPortMessage *) createMessageTo:(NSPort *)receiverPort withArray:(NSArray *)array fromPort:(NSPort *)senderPort;
- (NSData *) extractDataFrom:(NSPortMessage *)message;

@end

NS_ASSUME_NONNULL_END

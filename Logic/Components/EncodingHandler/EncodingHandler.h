//
//  EncodingHandler.h
//  MachPortsServer
//
//  Created by matan on 11/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncodingHandler : NSObject

- (NSData *) doSha256:(NSData *)dataIn;
- (NSData *) encodeData:(NSData *)data;
- (NSData *) encodeDataAndCalculateHash:(NSData *)messageData;
- (NSData *) encodeStringToData:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

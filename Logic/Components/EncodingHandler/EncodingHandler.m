//
//  EncodingHandler.m
//  MachPortsServer
//
//  Created by matan on 11/12/2022.
//

#import "EncodingHandler.h"
#import <CommonCrypto/CommonDigest.h>

@implementation EncodingHandler

- (NSData *) doSha256:(NSData *)dataIn{
    NSMutableData * macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG) dataIn.length, macOut.mutableBytes);
    
    return macOut;
}

- (NSData *) encodeDataAndCalculateHash:(NSData *)messageData{
    NSData * serializedData = [self encodeData:messageData];
    
    return [self doSha256:serializedData];
}

- (NSData *) encodeData:(NSData *)data{
    return [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:TRUE error:nil];
}

- (NSData *) encodeStringToData:(NSString *)string{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end

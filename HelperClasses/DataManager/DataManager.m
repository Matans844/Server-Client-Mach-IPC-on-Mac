//
//  Database.m
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import "DataManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <malloc/malloc.h>

#define MAX_SIZE_MSG 1024;

@implementation DataManager : NSObject

+ (NSData *) toNSData:(NSArray *)array{
    return [NSKeyedArchiver archivedDataWithRootObject:array requiringSecureCoding:TRUE error:nil];
}

+ (NSData *) doSha256:(NSData *)dataIn{
    NSMutableData * macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG) dataIn.length, macOut.mutableBytes);
    
    return macOut;
}

+ (NSData *) machMessageToSha256:(NSPortMessage *)message{
    NSArray * components = message.components;
    NSData * serializedComponents = [DataManager toNSData:components];
    
    return [DataManager doSha256:serializedComponents];
}

-(void) initiate{
    self.dictSenderToHash = [[NSMutableDictionary alloc] init];
    self.dictHashToComponents = [[NSMutableDictionary alloc] init];
    // self.dictMsgDataHashToMsg = [NSMutableDictionary dictionary];
}

-(NSMutableDictionary *) getDictSenderToHash{
    return self.dictSenderToHash;
}

-(NSMutableDictionary *) getDictHashToComponents{
    return self.dictHashToComponents;
}

- (void) addToDictSenderToHash: (NSPortMessage *) message{
    NSPort * senderPort = message.sendPort;
    NSData * hashCode = [DataManager machMessageToSha256:message];
    [[self getDictSenderToHash] setObject:hashCode forKey:senderPort];
}

- (void) addToDictHashToComponents: (NSPortMessage *) message{
    NSData * hashCode = [DataManager machMessageToSha256:message];
    NSArray * components = message.components;
    [[self getDictHashToComponents] setObject:components forKey:hashCode];
}

-(BOOL) saveData:(NSPortMessage *)message{
    NSPort * responsePort = message.sendPort;
    BOOL result = FALSE;
    
    if ([self isSenderActive:responsePort] && [self isDataValid:message] && [self isStorageVacant:responsePort]) {
        [self addToDictSenderToHash:message];
        [self addToDictHashToComponents:message];
        result = TRUE;
    }
    
    return result;
}

-(NSData * _Nullable) getData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];

    return [[self getDictHashToComponents] objectForKey:hashCode];
}

-(BOOL) isStorageVacant:(NSPort *)senderPort{
    BOOL result = ![[self getDictSenderToHash] objectForKey:senderPort];
    return result;
}

-(BOOL) isDataValid:(NSPortMessage *)message{
    BOOL sizeRequirement = malloc_size((__bridge const void *) message.components[0]) <= MAX_SIZE_MSG;
    return sizeRequirement;
}

-(BOOL) isSenderActive:(NSPort *)senderPort{
    return senderPort != nil;
}

@end

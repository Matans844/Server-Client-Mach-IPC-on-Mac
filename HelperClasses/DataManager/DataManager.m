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

// ------------------------------------ //

@interface DataManager()
// Idea: Can NSMapTable help with weak references to deactivated clients?

// "Private" properties
@property (atomic, retain, getter=getDictSenderToHash) NSMutableDictionary<NSPort*, NSData*> * dictSenderToHash;
@property (atomic, retain, getter=getDictHashToComponents) NSMutableDictionary<NSData*, NSArray*> * dictHashToComponents;

// "Private" methods
- (BOOL) isStorageVacant:(NSPort *)senderPort;
- (BOOL) isDataValid:(NSPortMessage *)message;
- (BOOL) isSenderActive:(NSPort *)senderPort;
- (void) addToDictSenderToHash: (NSPortMessage *) message;
- (void) addToDictHashToComponents: (NSPortMessage *) message;
- (void) initiate;

@end

// ------------------------------------ //

@implementation DataManager : NSObject

+ (NSData *) doSha256:(NSData *)dataIn{
    NSMutableData * macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG) dataIn.length, macOut.mutableBytes);
    
    return macOut;
}

+ (NSData *) machMessageToSha256:(NSPortMessage *)message{
    NSArray * components = message.components;
    NSData * serializedComponents = [NSKeyedArchiver archivedDataWithRootObject:components requiringSecureCoding:TRUE error:nil];
    
    return [DataManager doSha256:serializedComponents];
}

- (void) initiate{
    self.dictSenderToHash = [[NSMutableDictionary<NSPort*, NSData*> alloc] init];
    self.dictHashToComponents = [[NSMutableDictionary<NSData*, NSArray*> alloc] init];
}

- (id) init{
    self = [super init];
    if (self){
        [self initiate];
    }
    
    return self;
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

- (BOOL) saveData:(NSPortMessage *)message{
    NSPort * responsePort = message.sendPort;
    BOOL result = FALSE;
    
    if ([self isSenderActive:responsePort] && [self isDataValid:message] && [self isStorageVacant:responsePort]) {
        [self addToDictSenderToHash:message];
        [self addToDictHashToComponents:message];
        result = TRUE;
    }
    
    return result;
}

- (NSArray * _Nullable) getData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];
    NSArray * _Nullable target = [[self getDictHashToComponents] objectForKey:hashCode];
    
    return target;
}

- (void) removeData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];
    [[self getDictHashToComponents] removeObjectForKey:hashCode];
    [[self getDictSenderToHash] removeObjectForKey:sender];
}

- (BOOL) isStorageVacant:(NSPort *)senderPort{
    BOOL result = ![[self getDictSenderToHash] objectForKey:senderPort];
    return result;
}

- (BOOL) isDataValid:(NSPortMessage *)message{
    BOOL sizeRequirement = malloc_size((__bridge const void *) message.components[0]) <= MAX_SIZE_MSG;
    return sizeRequirement;
}

- (BOOL) isSenderActive:(NSPort *)senderPort{
    return senderPort != nil;
}

@end

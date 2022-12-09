//
//  Database.m
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import "DataManager.h"
#import <CommonCrypto/CommonDigest.h>

// ------------------------------------ //

@interface DataManager()
// Idea: Can NSMapTable help with weak references to deactivated clients?

// "Private" properties
@property (atomic, retain, getter=getMessageManager) MessageHandler * messageManager;
@property (atomic, retain, getter=getDictSenderToHash) NSMutableDictionary<NSPort*, NSData*> * dictSenderToHash;
// @property (atomic, retain, getter=getDictHashToComponents) NSMutableDictionary<NSData*, NSArray*> * dictHashToComponents;
@property (atomic, retain, getter=getDictHashToData) NSMutableDictionary<NSData*, NSData*> * dictHashToData;

// "Private" methods
- (BOOL) isStorageVacantForSender:(NSPort *)senderPort;
- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode;
// - (void) addToDictHashToComponents:(NSData *)hashCode withComponents:(NSArray *)components;
- (void) addToDictHashToData:(NSData *)hashCode withComponents:(NSData *)data;
- (void) initiateWith: (MessageHandler * _Nullable) messageManager;

@end

// ------------------------------------ //

@implementation DataManager : NSObject

+ (NSData *) doSha256:(NSData *)dataIn{
    NSMutableData * macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG) dataIn.length, macOut.mutableBytes);
    
    return macOut;
}

+ (NSData *) dataToSha256:(NSData *)messageData{
    NSData * serializedData = [NSKeyedArchiver archivedDataWithRootObject:messageData requiringSecureCoding:TRUE error:nil];
    
    return [DataManager doSha256:serializedData];
}

- (void) initiateWith:(MessageHandler * _Nullable)messageManager{
    self.messageManager = messageManager ? messageManager : [[MessageHandler alloc] init];;
    self.dictSenderToHash = [[NSMutableDictionary<NSPort*, NSData*> alloc] init];
    // self.dictHashToComponents = [[NSMutableDictionary<NSData*, NSArray*> alloc] init];
    self.dictHashToData = [[NSMutableDictionary<NSData*, NSData*> alloc] init];
}

- (id) init{
    return [self initWithMessageManager:nil];
}

- (id) initWithMessageManager:(MessageHandler *)messageManager{
    self = [super init];
    if(self){
        [self initiateWith:messageManager];
    }
    
    return self;
}

- (BOOL) isStorageVacantForSender:(NSPort *)senderPort{
    BOOL result = ![[self getDictSenderToHash] objectForKey:senderPort];
    return result;
}

- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode{
    [[self getDictSenderToHash] setObject:hashCode forKey:senderPort];
}

/*
- (void) addToDictHashToComponents:(NSData *)hashCode withComponents:(NSArray *)components{
    [[self getDictHashToComponents] setObject:components forKey:hashCode];
}
*/

- (void) addToDictHashToData:(NSData *)hashCode withComponents:(NSData *)data{
    [[self getDictHashToData] setObject:data forKey:hashCode];
}

- (BOOL) saveDataFrom:(NSPortMessage *)message{
    NSPort * responsePort = message.sendPort;
    BOOL result = FALSE;
    
    if ([self isStorageVacantForSender:responsePort]){
        NSData * messageData = [[self getMessageManager] extractDataFrom:message];
        NSData * hashCode = [DataManager dataToSha256:messageData];
        [self addToDictSenderToHash:responsePort withHash:hashCode];
        // [self addToDictHashToComponents:hashCode withComponents:message.components];
        [self addToDictHashToData:hashCode withComponents:messageData];
        result = TRUE;
    }
    
    return result;
}

/*
- (NSArray * _Nullable) getComponent:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];
    NSArray * _Nullable target = [[self getDictHashToComponents] objectForKey:hashCode];
    
    return target;
}
*/

- (NSData * _Nullable) getData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];

    return [[self getDictHashToData] objectForKey:hashCode];
}

- (void) removeSenderData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];
    // [[self getDictHashToComponents] removeObjectForKey:hashCode];
    
    // order is important here:
    // Had we first removed from dictSenderToHash, the hash value might not be valid anymore!
    [[self getDictHashToData] removeObjectForKey:hashCode];
    [[self getDictSenderToHash] removeObjectForKey:sender];
}






@end

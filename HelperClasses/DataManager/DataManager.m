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
@property (atomic, retain, getter=getDictHashToData) NSMutableDictionary<NSData*, NSData*> * dictHashToData;
@property (atomic, retain, getter=getCounterOfDataHash) NSMutableDictionary<NSData*, NSNumber*> * counterOfDataHash;


// "Private" methods
- (BOOL) isStorageVacantForSender:(NSPort *)senderPort;
- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode;
- (void) addToDictHashToData:(NSData *)hashCode withComponents:(NSData *)data;
- (void) addToCounterDataHash:(NSData *)hashCode;
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
    self.dictHashToData = [[NSMutableDictionary<NSData*, NSData*> alloc] init];
    self.counterOfDataHash = [[NSMutableDictionary<NSData*, NSNumber*> alloc] init];
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

- (void) addToDictHashToData:(NSData *)hashCode withComponents:(NSData *)data{
    [[self getDictHashToData] setObject:data forKey:hashCode];
}

- (void) addToCounterDataHash:(NSData *)hashCode{
    NSNumber * currentHashCodeCount = [[self getCounterOfDataHash] objectForKey:hashCode];
    
    // We check if the counter only contains a count for the hash code
    if(currentHashCodeCount){
        [[self getCounterOfDataHash] setObject:@([currentHashCodeCount intValue] + 1) forKey:hashCode];
    }
    else{
        [[self getCounterOfDataHash] setObject:@(1) forKey:hashCode];
    }
}

- (BOOL) saveDataFrom:(NSPortMessage *)message{
    NSPort * responsePort = message.sendPort;
    BOOL result = FALSE;
    
    if ([self isStorageVacantForSender:responsePort]){
        NSData * messageData = [[self getMessageManager] extractDataFrom:message];
        NSData * hashCode = [DataManager dataToSha256:messageData];
        [self addToDictSenderToHash:responsePort withHash:hashCode];
        [self addToDictHashToData:hashCode withComponents:messageData];
        [self addToCounterDataHash:hashCode];
        result = TRUE;
    }
    
    return result;
}

- (NSData * _Nullable) getData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];

    return [[self getDictHashToData] objectForKey:hashCode];
}

- (BOOL) removeSenderData:(NSPort *)sender{
    NSData * hashCode = [[self getDictSenderToHash] objectForKey:sender];
    BOOL result = FALSE;
    
    // Make sure there sender exists
    if (![self isStorageVacantForSender:sender]){
        NSNumber * currentHashCount = [[self getCounterOfDataHash] objectForKey:hashCode];
        
        // We only remove the hashCode if no other senders are linked to it.
        if ([currentHashCount intValue] == 1){
            [[self getDictHashToData] removeObjectForKey:hashCode];
            [[self getCounterOfDataHash] removeObjectForKey:hashCode];
        }
        else{
            [[self getCounterOfDataHash] setObject:@([currentHashCount intValue] - 1) forKey:hashCode];
        }
        
        // We remove the sender anyway.
        [[self getDictSenderToHash] removeObjectForKey:sender];
        
        result = TRUE;
    }
    
    return result;
}

@end

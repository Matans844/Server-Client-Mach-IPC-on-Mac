//
//  Database.m
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import "DataManager.h"
#import "MessageManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <malloc/malloc.h>

#define MAX_SIZE_MSG 1024;

// ------------------------------------ //

@interface DataManager()
// Idea: Can NSMapTable help with weak references to deactivated clients?

// "Private" properties
@property (atomic, retain, getter=getMessageManager) MessageManager * messageManager;
@property (atomic, retain, getter=getDictSenderToHash) NSMutableDictionary<NSPort*, NSData*> * dictSenderToHash;
@property (atomic, retain, getter=getDictHashToComponents) NSMutableDictionary<NSData*, NSArray*> * dictHashToComponents;

// "Private" methods
- (BOOL) isStorageVacant:(NSPort *)senderPort;
- (BOOL) isDataValid:(NSData *)messageData;
- (BOOL) isSenderActive:(NSPort *)senderPort;
- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode;
- (void) addToDictHashToComponents:(NSData *)hashCode withComponents:(NSArray *)components;
- (void) initiateWith: (MessageManager * _Nullable) messageManager;

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

- (void) initiateWith:(MessageManager * _Nullable)messageManager{
    self.messageManager = messageManager ? messageManager : [[MessageManager alloc] init];;
    self.dictSenderToHash = [[NSMutableDictionary<NSPort*, NSData*> alloc] init];
    self.dictHashToComponents = [[NSMutableDictionary<NSData*, NSArray*> alloc] init];
}

- (id) init{
    return [self initWithMessageManager:nil];
}

- (id) initWithMessageManager:(MessageManager *)messageManager{
    self = [super init];
    if(self){
        [self initiateWith:messageManager];
    }
    
    return self;
}

- (void) addToDictSenderToHash:(NSPort *)senderPort withHash:(NSData *)hashCode{
    [[self getDictSenderToHash] setObject:hashCode forKey:senderPort];
}

- (void) addToDictHashToComponents:(NSData *)hashCode withComponents:(NSArray *)components{
    [[self getDictHashToComponents] setObject:components forKey:hashCode];
}

- (BOOL) saveData:(NSPortMessage *)message{
    NSPort * responsePort = message.sendPort;
    NSData * messageData = [[self getMessageManager] extractDataFrom:message];
    
    BOOL result = FALSE;
    
    if ([self isSenderActive:responsePort] && [self isDataValid:messageData] && [self isStorageVacant:responsePort]) {
        NSData * hashCode = [DataManager dataToSha256:messageData];
        [self addToDictSenderToHash:responsePort withHash:hashCode];
        [self addToDictHashToComponents:hashCode withComponents:message.components];
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

- (BOOL) isDataValid:(NSData *)messageData{
    BOOL sizeRequirement = malloc_size((__bridge const void *) messageData) <= MAX_SIZE_MSG;
    return sizeRequirement;
}

- (BOOL) isSenderActive:(NSPort *)senderPort{
    return senderPort != nil;
}

@end

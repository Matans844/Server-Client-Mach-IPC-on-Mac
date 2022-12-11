//
//  Database.m
//  MachPortsServer
//
//  Created by matan on 06/12/2022.
//

#import "DataManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSMutableDictionaryWrapper.h"
#import "EncodingHandler.h"

// ------------------------------------ //

@interface DataManager()

// "Private" properties
@property (atomic, assign, readonly, getter=getChosenCorrespondent) eRoleInCommunication chosenCorrespondent;
@property (atomic, retain, readonly, getter=getMessageManager) MessageHandler * messageHandler;
@property (atomic, retain, readonly, getter=getEncodingHandler) EncodingHandler * encodingHandler;
@property (atomic, retain, readonly, getter=getDictCorrespondentToHashWrapper) NSMutableDictionaryWrapper * dictCorrespondentToHash;
@property (atomic, retain, readonly, getter=getDictHashToDataWrapper) NSMutableDictionaryWrapper * dictHashToData;
@property (atomic, retain, readonly, getter=getCounterOfDataHashWrapper) NSMutableDictionaryWrapper * counterOfDataHash;

// "Private" methods
- (BOOL) isStorageVacantForCorrespondent:(NSPort *)chosenCorrespondent;
- (BOOL) isStorageVacantForHash:(NSData *)hashCode;
- (void) addToDictCorrespondentToHash:(NSPort *)chosenCorrespondent withHash:(NSData *)hashCode;
- (void) addToDictHashToData:(NSData *)hashCode withData:(NSData *)data;
- (void) addToCounterDataHash:(NSData *)hashCode;
- (NSData *) getHashCodeFromCorrespondent:(NSPort *)chosenCorrespondent;
- (NSString *) describeContent;
- (NSMutableDictionary<NSPort*, NSData*> *) getDictCorrespondentToHash;
- (NSMutableDictionary<NSData*, NSData*> *) getDictHashToData;
- (NSMutableDictionary<NSData*, NSNumber*> *) getCounterOfDataHash;

@end

// ------------------------------------ //

@implementation DataManager : NSObject

/*
+ (NSData *) doSha256:(NSData *)dataIn{
    NSMutableData * macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG) dataIn.length, macOut.mutableBytes);
    
    return macOut;
}

+ (NSData *) encodeDataAndCalculateHash:(NSData *)messageData{
    NSData * serializedData = [DataManager encodeData:messageData];
    
    return [DataManager doSha256:serializedData];
}

+ (NSData *) encodeData:(NSData *)data{
    return [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:TRUE error:nil];
}
 */

- (NSMutableDictionary<NSPort*, NSData*> *) getDictCorrespondentToHash{
    return [[self getDictCorrespondentToHashWrapper] getWrappedDictionary];
}

- (NSMutableDictionary<NSData*, NSData*> *) getDictHashToData{
    return [[self getDictHashToDataWrapper] getWrappedDictionary];
}

- (NSMutableDictionary<NSData*, NSNumber*> *) getCounterOfDataHash{
    return [[self getCounterOfDataHashWrapper] getWrappedDictionary];
}

- (id) initWithMessageHandler:(MessageHandler *)messageManager chosenCorrespondent:(eRoleInCommunication)keyCorrespondent{
    self = [super init];
    if(self){
        self->_chosenCorrespondent = keyCorrespondent;
        self->_messageHandler = [[MessageHandler alloc] init];
        self->_encodingHandler = [[EncodingHandler alloc] init];
        
        NSMutableDictionary * dictCorrespondentToHashInstance = [[NSMutableDictionary<NSPort*, NSData*> alloc] init];
        NSMutableDictionary * dictHashToDataInstance = [[NSMutableDictionary<NSData*, NSData*> alloc] init];
        NSMutableDictionary * counterOfDataHashInstance = [[NSMutableDictionary<NSData*, NSNumber*> alloc] init];
                
        self->_dictCorrespondentToHash = [[NSMutableDictionaryWrapper alloc] initWithName:@"Dictionary: Correspondent to Hash" dictInstance:dictCorrespondentToHashInstance];
        self->_dictHashToData = [[NSMutableDictionaryWrapper alloc] initWithName:@"Dictionary: Hash to Data" dictInstance:dictHashToDataInstance];
        self->_counterOfDataHash = [[NSMutableDictionaryWrapper alloc] initWithName:@"Dictionary: Hash to Count" dictInstance:counterOfDataHashInstance];
    }
    
    return self;
}

- (BOOL) isStorageVacantForCorrespondent:(NSPort *)chosenCorrespondent{
    BOOL result = ![[self getDictCorrespondentToHash] objectForKey:chosenCorrespondent];
    return result;
}

- (BOOL) isStorageVacantForHash:(NSData *)hashCode{
    BOOL result = ![[self getDictHashToData] objectForKey:hashCode];
    
    return result;
}

- (void) addToDictCorrespondentToHash:(NSPort *)chosenCorrespondent withHash:(NSData *)hashCode{
    [[self getDictCorrespondentToHash] setObject:hashCode forKey:chosenCorrespondent];
}

- (void) addToDictHashToData:(NSData *)hashCode withData:(NSData *)data{
    [[self getDictHashToData] setObject:data forKey:hashCode];
}

- (void) addToCounterDataHash:(NSData *)hashCode{
    NSNumber * currentHashCodeCount = [[self getCounterOfDataHash] objectForKey:hashCode];
    
    // We check if the counter only contains a count for the hash code
    if(currentHashCodeCount){
        [[self getCounterOfDataHash] setObject:@([currentHashCodeCount intValue] + 1) forKey:hashCode];
    }
    else{
        [[self getCounterOfDataHash] setObject:@(START_OF_COUNTER_COUNT) forKey:hashCode];
    }
}

- (BOOL) saveDataFromMessage:(NSPortMessage *)message{
    NSPort * senderPort = message.sendPort;
    NSPort * receiverPort = message.receivePort;
    NSPort * keyCorrespondentPort = [self getChosenCorrespondent] == serverSide ? senderPort : receiverPort;
    BOOL result = FALSE;
    
    if ([self isStorageVacantForCorrespondent:keyCorrespondentPort]){
        
        // There are new key correspondents for the data.
        // We update the correspondent to hash dictionary.
        NSData * messageData = [[self getMessageManager] extractDataFrom:message];
        NSData * hashCode = [[self getEncodingHandler] encodeDataAndCalculateHash:messageData];
        [self addToDictCorrespondentToHash:keyCorrespondentPort withHash:hashCode];
        [self addToCounterDataHash:hashCode];
        
        // We only update the hash to original data dictionary if the hash is new
        if ([self isStorageVacantForHash:hashCode]){
            [self addToDictHashToData:hashCode withData:messageData];
        }
        
        result = TRUE;
    }
    
    return result;
}

- (NSData * _Nullable) getDataByCorrespondent:(NSPort *)chosenCorrespondent{
    NSData * hashCode = [self getHashCodeFromCorrespondent:chosenCorrespondent];

    return [[self getDictHashToData] objectForKey:hashCode];
}

- (NSData *) getHashCodeFromCorrespondent:(NSPort *)chosenCorrespondent{
    return [[self getDictCorrespondentToHash] objectForKey:chosenCorrespondent];
}

- (BOOL) removeDataByKeyCorrespondent:(NSPort *)chosenCorrespondent{
    NSData * hashCode = [[self getDictCorrespondentToHash] objectForKey:chosenCorrespondent];
    BOOL result = FALSE;
    
    // Make sure correspondent key exists
    if (![self isStorageVacantForCorrespondent:chosenCorrespondent]){
        NSNumber * currentHashCount = [[self getCounterOfDataHash] objectForKey:hashCode];
        
        // We only remove the hashCode if no other correspondent keys are linked to it.
        if ([currentHashCount intValue] == 1){
            [[self getDictHashToData] removeObjectForKey:hashCode];
            [[self getCounterOfDataHash] removeObjectForKey:hashCode];
        }
        else{
            [[self getCounterOfDataHash] setObject:@([currentHashCount intValue] - 1) forKey:hashCode];
        }
                
        // We remove the key correspondent entry anyway.
        // Notice:
        // 1. A sender (client) can have at most one data record in its data manager from the receiver (server).
        // 2. A receiver (server) can have at most one data record in its data manager from the sender (client).
        [[self getDictCorrespondentToHash] removeObjectForKey:chosenCorrespondent];
                
        result = TRUE;
    }
    
    return result;
}

- (NSString *) describeContent{
    NSString * headline = @"Content:";
    NSString * descriptionDictCorrespondentToHash = [NSString stringWithFormat:@"%@", [self getDictCorrespondentToHashWrapper]];
    NSString * descriptionDictHashToData = [NSString stringWithFormat:@"%@", [self getDictHashToDataWrapper]];
    NSString * descriptionCounter = [NSString stringWithFormat:@"%@", [self getCounterOfDataHashWrapper]];;
    
    return [NSString stringWithFormat:@"%@\n1): %@2): %@3): %@", headline, descriptionDictCorrespondentToHash, descriptionDictHashToData, descriptionCounter];
}

- (NSString *) description{
    NSString * headline = @"Data Manager Object: Contains 3 dictionaries.\n";
    NSString * descriptionContent = [self describeContent];
    NSString * endOfDescription = @"\n";
    
    return [NSString stringWithFormat:@"%@%@%@", headline, descriptionContent, endOfDescription];
}

@end

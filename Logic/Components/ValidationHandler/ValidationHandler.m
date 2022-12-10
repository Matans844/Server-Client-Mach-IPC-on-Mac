//
//  ValidationHandler.m
//  MachPortsServer
//
//  Created by matan on 08/12/2022.
//

#import "ValidationHandler.h"
#import <malloc/malloc.h>

// ------------------------------------ //

@interface ValidationHandler()

// "Private" properties
// [This is a very lonely space]
// "Private" methods
- (BOOL) isComponentsInCorrectSize:(NSArray *)components;
- (BOOL) isComponentsInArrangedStructure:(NSArray *)components;
- (BOOL) isMessageComponentArrangementValid:(NSArray *)components;
- (BOOL) isMessageComponentsSizeValid:(NSArray *)components;
- (BOOL) isSenderActive:(NSPort *)senderPort;
- (BOOL) isMessageComponentsValid:(NSArray *)components;
- (NSUInteger) calculateComponentsSizeInBytes:(NSArray *)components;


@end

// ------------------------------------ //

@implementation ValidationHandler

- (BOOL) isComponentsInCorrectSize:(NSArray *)components{
    return [components count] == DEFAULT_STRUCTURED_COMPONENT_SIZE;
}

- (BOOL) isComponentsInArrangedStructure:(NSArray *)components{
    return [[components objectAtIndex:indexOfComponentArrangementFlag] intValue] == arrangedByStructuredArrangement;
}

- (BOOL) isMessageComponentArrangementValid:(NSArray *)components{
    // Checking for size, arrangement, type.
    // We are only checking value for the component arrangement flag.
    return [self isComponentsInCorrectSize:components] && [self isComponentsInArrangedStructure:components] && [self isComponentsCellsInCorrectType:components];
}

- (BOOL) isMessageComponentsSizeValid:(NSArray *)components{
    return [self calculateComponentsSizeInBytes:components] <= MAX_SIZE_MSG;
}

- (BOOL) isComponentsCellsInCorrectType:(NSArray *)components{
    // We are placing the enums (which are static entities) in an NSNumber wrapper
    BOOL check1 = [components[indexOfData] isKindOfClass:[NSData class]];
    BOOL check2 = [components[indexOfRequestedFunctionality] isKindOfClass:[NSNumber class]];
    BOOL check3 = [components[indexOfRequestResult] isKindOfClass:[NSNumber class]];
    BOOL check4 = [components[indexOfComponentArrangementFlag] isKindOfClass:[NSNumber class]];
    
    return check1 && check2 && check3 && check4;
}

- (BOOL) isSenderActive:(NSPort *)senderPort{
    return senderPort != nil;
}

- (BOOL) isMessageComponentsValid:(NSArray *)components{
    return [self isMessageComponentsSizeValid:components] && [self isMessageComponentArrangementValid:components];
}

- (NSUInteger) calculateComponentsSizeInBytes:(NSArray *)components{
    id obj = nil;
    NSUInteger totalSize = 0;
    for(obj in components){
        totalSize += malloc_size((__bridge const void *) obj);
    }
    
    return totalSize;
}

- (BOOL) isMessageValid:(NSPortMessage *)message{
    return [self isSenderActive:message.sendPort] && [self isMessageComponentsValid:message.components];
}


@end

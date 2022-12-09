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

// "Private" methods
- (BOOL) isComponentsInCorrectSize:(NSArray *)components;
- (BOOL) isComponentsInArrangedStructure:(NSArray *)components;
- (BOOL) isMessageComponentArrangementValid:(NSArray *)components;
- (BOOL) isMessageComponentsSizeValid:(NSArray *) components;
- (BOOL) isSenderActive:(NSPort *)senderPort;
- (BOOL) isMessageComponentsValid:(NSArray *)components;
- (NSUInteger) calculateComponentsSizeInBytes:(NSArray *) components;


@end

// ------------------------------------ //

@implementation ValidationHandler

- (BOOL) isComponentsInCorrectSize:(NSArray *)components{
    return [components count] == [ValidationHandler defaultMessageStructureSize];
}

- (BOOL) isComponentsInArrangedStructure:(NSArray *)components{
    return [[components objectAtIndex:componentArrangementFlag] intValue] == notArrangedByStructuredArrangement;
}

- (BOOL) isMessageComponentArrangementValid:(NSArray *)components{
    return [self isComponentsInCorrectSize:components] && [self isComponentsInArrangedStructure:components];
}

- (BOOL) isMessageComponentsSizeValid:(NSArray *) components{
    return [self calculateComponentsSizeInBytes:components] <= MAX_SIZE_MSG;
    
}

- (BOOL) isSenderActive:(NSPort *)senderPort{
    return senderPort != nil;
}

- (BOOL) isMessageComponentsValid:(NSArray *)components{
    return [self isMessageComponentsSizeValid:components] && [self isMessageComponentArrangementValid:components];
}

- (NSUInteger) calculateComponentsSizeInBytes:(NSArray *) components{
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

+ (NSUInteger) defaultMessageStructureSize{
    return 4;
}


@end

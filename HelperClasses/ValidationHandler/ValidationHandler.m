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
- (BOOL) isComponentsInCorrectStructure:(NSArray *)components;
- (BOOL) isMessageComponentStructureValid:(NSArray *)components;
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

- (BOOL) isComponentsInCorrectStructure:(NSArray *)components{
    return [[components objectAtIndex:componentArrangementFlag] intValue] == composite;
}

- (BOOL) isMessageComponentStructureValid:(NSArray *)components{
    return [self isComponentsInCorrectSize:components] && [self isComponentsInCorrectStructure:components];
}

- (BOOL) isMessageComponentsSizeValid:(NSArray *) components{
    return [self calculateComponentsSizeInBytes:components] <= MAX_SIZE_MSG;
    
}

- (BOOL) isSenderActive:(NSPort *)senderPort{
    return senderPort != nil;
}

- (BOOL) isMessageComponentsValid:(NSArray *)components{
    return [self isMessageComponentsSizeValid:components] && [self isMessageComponentStructureValid:components];
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
    return [self isSenderActive:message.sendPort] && [self isMessageComponentStructureValid:message.components];
}

+ (NSUInteger) defaultMessageStructureSize{
    return 4;
}


@end

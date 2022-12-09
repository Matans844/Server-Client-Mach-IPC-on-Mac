//
//  ValidationHandler.h
//  MachPortsServer
//
//  Created by matan on 08/12/2022.
//

#import <Foundation/Foundation.h>
#import "definitions.h"

NS_ASSUME_NONNULL_BEGIN

@interface ValidationHandler : NSObject

// + (NSUInteger) defaultMessageStructureSize;

- (BOOL) isMessageValid:(NSPortMessage *)message;


@end

NS_ASSUME_NONNULL_END

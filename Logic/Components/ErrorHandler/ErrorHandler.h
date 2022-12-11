//
//  ErrorHandler.h
//  MachPortsServer
//
//  Created by matan on 11/12/2022.
//

#import <Foundation/Foundation.h>

#define ERROR_CODE_TO_DO 1

NS_ASSUME_NONNULL_BEGIN

@interface ErrorHandler : NSObject

+ exitProgramOnError;

@end

NS_ASSUME_NONNULL_END

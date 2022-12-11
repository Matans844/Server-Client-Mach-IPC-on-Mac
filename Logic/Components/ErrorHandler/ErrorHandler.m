//
//  ErrorHandler.m
//  MachPortsServer
//
//  Created by matan on 11/12/2022.
//

#import "ErrorHandler.h"

@implementation ErrorHandler

+ exitProgramOnError{
    NSLog(@"error\n");
    // TODO: Define Error type
    exit(ERROR_CODE_TO_DO);
}

@end

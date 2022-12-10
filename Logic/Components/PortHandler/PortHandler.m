//
//  PortHandler.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "PortHandler.h"

@implementation PortHandler

- (NSPort *)getPortByName:(NSString*)serviceName{
    return [[NSMachBootstrapServer sharedInstance] portForName:serviceName];
}

- (NSPort *) initiatePortWithString:(NSString *)serviceName{
    NSPort * _Nullable result = [[NSMachBootstrapServer sharedInstance] servicePortWithName:serviceName];
    
    if(result == nil){
        // This probably means another instance is running
        NSLog(@"Unable to open server port for %@.", serviceName);
        // We copy the existing porty
        result = [self getPortByName:serviceName];
    }
    
    return result;
}

@end

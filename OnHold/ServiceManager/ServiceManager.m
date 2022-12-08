//
//  ServiceManager.m
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import "ServiceManager.h"

@implementation ServiceManager

- (void) initiate{
    self.dictPortToService = [[NSMutableDictionary<NSPort*, NSObject<NSPortDelegate>*> alloc] init];
}

- (void) addService:(NSPort *)portToListen withDelegate:(NSObject<NSPortDelegate> *)serviceListener{
    
}

@end

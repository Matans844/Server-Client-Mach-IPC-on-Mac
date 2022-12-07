//
//  ServiceManager.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>
#import "Service.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceManager : NSObject

@property NSMutableDictionary<NSPort*, Service*> * dictPortToService;

- (void) initiate;
- (void) addService:(Service *) service;

@end

NS_ASSUME_NONNULL_END

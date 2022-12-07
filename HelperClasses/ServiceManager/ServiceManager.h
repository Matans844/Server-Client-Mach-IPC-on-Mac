//
//  ServiceManager.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServiceManager : NSObject

@property NSMutableDictionary<NSPort*, NSObject<NSPortDelegate>*> * dictPortToService;

- (void) initiate;
- (void) addService:(NSPort *) portToListen withDelegate:(NSObject<NSPortDelegate> *) serviceListener;

@end

NS_ASSUME_NONNULL_END

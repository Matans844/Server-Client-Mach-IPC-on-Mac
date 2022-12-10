//
//  PortHandler.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PortHandler : NSObject

- (NSPort *) getPortByName:(NSString*) serviceName;
- (NSPort *) initiatePortWithString:(NSString *)serviceName;

@end

NS_ASSUME_NONNULL_END

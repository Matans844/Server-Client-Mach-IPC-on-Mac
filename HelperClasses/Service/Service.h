//
//  Service.h
//  MachPortsServer
//
//  Created by matan on 07/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Service : NSObject<NSPortDelegate>

@property NSPort * port;

- (void) setPort: (NSPort *) portToListen withName: (const NSString *) serviceName;
- (NSPort *) getPort;


@end

NS_ASSUME_NONNULL_END

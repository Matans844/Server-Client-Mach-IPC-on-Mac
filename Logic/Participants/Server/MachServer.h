//
//  MachServer.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>
#import "Correspondent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MachServer : Correspondent<NSPortDelegate>

- (void) initiateEventLoop;
- (void) save:(NSPortMessage *)message;
- (void) send:(NSPortMessage *)message;
- (void) printData;

@end

NS_ASSUME_NONNULL_END

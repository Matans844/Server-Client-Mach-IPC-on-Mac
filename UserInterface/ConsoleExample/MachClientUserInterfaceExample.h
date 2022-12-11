//
//  MachClientUI.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>
#import "MachClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface MachClientUserInterfaceExample : NSObject

@property (atomic, retain, readonly, getter=getClient) MachClient * clientObject;

- (id) initWithClientLogicObject:(MachClient *)clientInstance NS_DESIGNATED_INITIALIZER;
- (id) init NS_UNAVAILABLE;

- (void) exampleSaveData;
- (void) exampleGetData;
- (void) exampleVerifyData;

@end

NS_ASSUME_NONNULL_END

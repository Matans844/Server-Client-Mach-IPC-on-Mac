//
//  MachPortClient.h
//  MachPortsClient
//
//  Created by matan on 05/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MachPortsClient: NSObject<NSPortDelegate>
{
    BOOL _responseReceived;
}

-(void)sendStringMessage:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

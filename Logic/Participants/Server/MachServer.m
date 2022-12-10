//
//  MachServer.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachServer.h"

@implementation MachServer

-(void) handlePortMessage:(NSPortMessage *)message
{
    /*
    NSPort * responsePort = message.sendPort;
    if (responsePort != nil){
        // sender is still active
        NSArray * components = message.components;
        if (components.count > 0){
            NSString * data = [[NSString alloc] initWithData:components[0] encoding:NSUTF8StringEncoding];
            NSLog(@"Received data: \"%@\"", data);
        }
        
        NSPortMessage * response = [[NSPortMessage alloc] initWithSendPort:responsePort receivePort:nil components:message.components];
        response.msgid = message.msgid;
        NSDate * timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
        [response sendBeforeDate:timeout];
        NSLog(@"Sent feedback response");
    }
     */
}

@end

//
//  MachClient.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "MachClient.h"

@implementation MachClient


- (void) sendDataToSaveAt:(NSPort *)senderPort withData:(NSData *)messageData{
    
}

- (void) removeDataToSaveAt:(NSPort *)senderPort{
    
}

- (NSData *) receiveDataSaveAt:(NSPort *)senderPort{
    
}

- (BOOL) compareData:(NSData *)receivedData otherData:(NSData *)originalData{
    return [originalData isEqual:receivedData];
}

- (NSPort *) findServerByName:(NSString *)serverName{
    return [[self getPortHandler] getPortByName:serverName];
}


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

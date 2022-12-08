//
//  MachPortServer.m
//  MachPortsServer
//
//  Created by matan on 05/12/2022.
//

#import "MachPortsServer.h"
#import <CommonCrypto/CommonDigest.h>

#define SERVICE_NAME @"org.matans.save"

@implementation MachPortsServer

-(void) initiate
{
    self.port = [[NSMachBootstrapServer sharedInstance] servicePortWithName:SERVICE_NAME];
    if (self.port == nil){
        // This probably means another instance is running
        NSLog(@"Unable to open server port.");
        return;
    }
    
    self.dictSenderPortToMsgIDs = [NSMutableDictionary dictionary];
    self.dictMsgIDToMsg = [NSMutableDictionary dictionary];
    self.dictMsgDataHashToMsgID = [NSMutableDictionary dictionary];
    
    self.port.delegate = self;
    
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:self.port forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

-(void) handlePortMessage:(NSPortMessage *)message
{
    NSPort * responsePort = message.sendPort;
    if (responsePort != nil){
        // sender is still active
        
        
        /*
        NSData * contentDataHash = [MachPortsServer doSha256:message.components];
        NSData * isDataNew = self.dictMsgDataHashToMsgID[];
        
        
        NSMutableDictionary * dictSenderPortToMsgID = self.dictSenderPortToMsgIDs[responsePort];
        
        if(dictSenderPortToMsgID != nil){
            // sender has already sent something
            
            NSNumber * msgID = dictSenderPortToMsgID[responsePort];
            if(msgID != nil){
                
            }
        }
        */
        
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
}

@end

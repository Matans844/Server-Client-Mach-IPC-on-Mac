//
//  main.m
//  MachPortsServer
//
//  Created by matan on 05/12/2022.
//

#import <Foundation/Foundation.h>
#import "MachPortsServer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MachPortsServer * server = [MachPortsServer new];
        [server initiate];
    }
    return 0;
}

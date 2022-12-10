//
//  DictionaryWithName.m
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import "NSMutableDictionaryWrapper.h"

@implementation NSMutableDictionaryWrapper

- (id) initWithName:(nonnull NSString *)name dictInstance:(nonnull NSMutableDictionary * )instance{
    self = [super init];
    if(self){
        self->_dictionaryName = name;
        self->_mutableDictionary = instance;
    }
    
    return self;
}

- (NSString *) describeContent{
    NSMutableString * stringDictionaryInfo = [[NSMutableString alloc] init];
    [stringDictionaryInfo appendFormat: @"Key : Value pairs\n"];
    for(id key in [self getWrappedDictionary]){
        [stringDictionaryInfo appendFormat:@"%@ : %@\n", key, [[self getWrappedDictionary] objectForKey:key]];
    }
    
    return [NSString stringWithString:stringDictionaryInfo];
}

- (NSString *) description{
    NSString * headline = [self getSelfName];
    
    NSString * descriptionContent = [self describeContent];
    
    return [NSString stringWithFormat:@"%@\n%@", headline, descriptionContent];
}

@end

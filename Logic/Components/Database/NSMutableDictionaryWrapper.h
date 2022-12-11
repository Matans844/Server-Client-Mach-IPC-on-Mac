//
//  DictionaryWithName.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionaryWrapper : NSObject

@property (atomic, readonly, getter=getSelfName) NSString * dictionaryName;

// To maintain generic behavior of NSMutableDictionary:
// 1. I initialize it with generics outside the current init.
// 2. I add the pointer to it.
// I kept the "retain" attribute, although it being default, to highlight this implementation detail.
@property (atomic, retain, readonly, getter=getWrappedDictionary) NSMutableDictionary * mutableDictionary;

- (id) initWithName:(nonnull NSString *)name dictInstance:(nonnull NSMutableDictionary * )instance NS_DESIGNATED_INITIALIZER;
- (id) init NS_UNAVAILABLE;
- (NSString *) describeContent;

@end

NS_ASSUME_NONNULL_END

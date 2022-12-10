//
//  DictionaryWithName.h
//  MachPortsServer
//
//  Created by matan on 10/12/2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionaryWrapper : NSObject

@property (atomic, retain, readonly, getter=getSelfName) NSString * dictionaryName;
@property (atomic, retain, readonly, getter=getWrappedDictionary) NSMutableDictionary * mutableDictionary;

- (id) initWithName:(nonnull NSString *)name dictInstance:(nonnull NSMutableDictionary * )instance NS_DESIGNATED_INITIALIZER;
- (id) init NS_UNAVAILABLE;

- (NSString *) describeContent;

@end

NS_ASSUME_NONNULL_END

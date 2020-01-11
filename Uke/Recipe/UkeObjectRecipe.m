//
//  UkeObjectRecipe.m
//  Uke
//
//  Created by Gil on 1/9/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import "UkeObjectRecipe.h"

@implementation UkeObjectRecipe {
    NSMutableDictionary *_constants;
}

- (nullable instancetype)initWithBaseClassName:(NSString *)baseClassName {
    Class baseClass = NSClassFromString(baseClassName);
    return baseClass ? [self initWithBaseClass:baseClass] : nil;
}

- (instancetype)initWithBaseClass:(Class)baseClass {
    if (self = [super init]) {
        _constants = [[NSMutableDictionary alloc] init];
        self.baseClass = baseClass;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _constants = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addConstant:(id)value forKeyPath:(NSString *)keyPath {
    [_constants setObject:value forKey:keyPath];
}

- (NSObject *)instantiate {
    NSObject *object = [[_baseClass alloc] init];
    for (NSString *keyPath in _constants) {
        [object setValue:[_constants objectForKey:keyPath] forKeyPath:keyPath];
    }
    return object;
}

@end

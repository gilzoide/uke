//
//  NSObject+Instantiate.m
//  Uke
//
//  Created by Gil Reis on 29/03/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import "NSObject+Instantiate.h"

@implementation NSObject (Instantiate)

+ (nullable NSObject *)instantiate:(Class baseClass) {
    return [baseClass new];
}

@end

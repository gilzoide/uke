//
//  NSObject+Instantiate.h
//  Uke
//
//  Created by Gil Reis on 29/03/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Instantiate)

+ (nullable NSObject *)instantiate:(Class)baseClass;

@end

NS_ASSUME_NONNULL_END

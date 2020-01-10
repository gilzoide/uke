//
//  UkeObjectRecipe.h
//  Uke
//
//  Created by Gil on 1/9/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UkeObjectRecipe : NSObject

@property (nonatomic, strong, readonly) Class baseClass;

- (nullable instancetype)initWithBaseClassName:(NSString *)baseClassName;
- (instancetype)initWithBaseClass:(Class)baseClass;

- (void)addConstant:(id)value forKeyPath:(NSString *)keyPath;
- (NSObject *)instantiate;

@end

NS_ASSUME_NONNULL_END

//
//  UkeEngine.h
//  UkeLua
//
//  Created by Gil on 1/15/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UkeTemplate;
typedef struct lua_State lua_State;

NS_ASSUME_NONNULL_BEGIN

@interface UkeEngine : NSObject

- (nullable UkeTemplate *)templateNamed:(NSString *)name;
@property (nonatomic, readonly, assign) lua_State *luaState;

@end

NS_ASSUME_NONNULL_END

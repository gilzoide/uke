//
//  UkeEngine.m
//  UkeLua
//
//  Created by Gil on 1/15/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import "UkeEngine.h"
#import "UkeLuaBridge.h"
#import <UkeLua/UkeLua-Swift.h>

#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"
#import <UIKit/UIKit.h>

// Prototype for requiring lpeglabel without building a dynamic library
int luaopen_lpeglabel (lua_State *L);

@implementation UkeEngine {
    lua_State *L;
    NSMutableDictionary *_templateCache;
}

- (instancetype)init {
    if (self = [super init]) {
        L = luaL_newstate();
        luaL_openlibs(L);
        UkeRegisterMetatable(L);
        [self requireLpegLabel];
        [self requireUkeLua];
        _templateCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    lua_close(L);
    L = NULL;
}

- (lua_State *)luaState {
    return L;
}

- (nullable UkeTemplate *)templateNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"lua"];
    if (!path) return nil;
    
    const char *nameC = name.UTF8String;
    lua_getfield(L, LUA_REGISTRYINDEX, nameC);
    
    
    UkeTemplate *template = [_templateCache objectForKey:name];
    if (template) return template;
    
    if (luaL_loadfile(L, path.UTF8String) != LUA_OK) {
        const char *reason = lua_tostring(L, -1);
        @throw [NSException exceptionWithName:@"OOHNOO" reason:[NSString stringWithUTF8String:reason] userInfo:nil];
    }
    else {
        lua_setfield(L, LUA_REGISTRYINDEX, nameC);
    }
    
    return template;
}

- (void)requireLpegLabel {
    luaL_requiref(L, "lpeglabel", luaopen_lpeglabel, 0);
    luaL_requiref(L, "relabel", UkeRequireLuaFile, 0);
}

- (void)requireUkeLua {
    luaL_requiref(L, "uke", UkeRequireLuaFile, 0);
}

@end

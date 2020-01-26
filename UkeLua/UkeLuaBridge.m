//
//  UkeLuaBridge.m
//  UkeLua
//
//  Created by Gil on 1/16/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import "UkeLuaBridge.h"
#import "UkeEngine.h"

#import <objc/runtime.h>
#import "lauxlib.h"

#define METATABLE_NAME "NSObject"

typedef struct UkeLuaBridgeObject {
    void *objPtr;
} UkeLuaBridgeObject;

static inline id UkeWrappedObj(UkeLuaBridgeObject *wrapper) {
    return (__bridge id)wrapper->objPtr;
}

int _NSObjectIndex(lua_State *L) {
    UkeLuaBridgeObject *wrapper = luaL_checkudata(L, 1, METATABLE_NAME);
    const char *name = luaL_checkstring(L, 2);
    if (wrapper && name) {
        id obj = UkeWrappedObj(wrapper);
        @try {
            id value = [obj valueForKey:[NSString stringWithUTF8String:name]];
            UkePushObject(L, value);
        } @catch (NSException *exception) {
            lua_getglobal(L, name);
        }
        return 1;
    }
    return 0;
}

int _NSObjectNewindex(lua_State *L) {
    UkeLuaBridgeObject *wrapper = luaL_checkudata(L, 1, METATABLE_NAME);
    const char *name = luaL_checkstring(L, 2);
    id value = UkeToobject(L, 3);
    if (wrapper && name && value) {
        id obj = UkeWrappedObj(wrapper);
        @try {
            [obj setValue:value forKey:[NSString stringWithUTF8String:name]];
        } @catch (NSException *exception) {
            luaL_error(L, "NSObject.__newindex: %s", exception.reason.UTF8String);
        }
    }
    return 0;
}

int _NSObjectGc(lua_State *L) {
    UkeLuaBridgeObject *wrapper = luaL_checkudata(L, 1, METATABLE_NAME);
    CFRelease(wrapper->objPtr);
    wrapper->objPtr = nil;
    return 0;
}

int _NSObjectTostring(lua_State *L) {
    UkeLuaBridgeObject *wrapper = luaL_checkudata(L, 1, METATABLE_NAME);
    if (wrapper) {
        id obj = UkeWrappedObj(wrapper);
        lua_pushstring(L, [NSString stringWithFormat:@"%@", obj].UTF8String);
    }
    return wrapper != NULL;
}

void UkeRegisterMetatable(lua_State *L) {
    if (luaL_newmetatable(L, METATABLE_NAME)) {
        luaL_Reg metamethods[] = {
            { "__index", _NSObjectIndex },
            { "__newindex", _NSObjectNewindex },
            { "__gc", _NSObjectGc },
            { "__tostring", _NSObjectTostring },
            { NULL, NULL }
        };
        luaL_setfuncs(L, metamethods, 0);
    }
    lua_pop(L, 1);
}

BOOL UkePushObject(lua_State *L, id object) {
    if( ! object )
        lua_pushnil(L);
    else if( [object isKindOfClass:[NSString class]] )
        lua_pushstring(L, [object UTF8String]);
    else if( [object isKindOfClass:[NSNumber class]] ) {
        switch( [object objCType][0] ) {
            case _C_FLT:
            case _C_DBL:
                lua_pushnumber(L, [object doubleValue]);
                break;
            case _C_CHR:
            case _C_UCHR:
                lua_pushboolean(L, [object boolValue]);
                break;
            case _C_SHT:
            case _C_USHT:
            case _C_INT:
            case _C_UINT:
            case _C_LNG:
            case _C_ULNG:
            case _C_LNG_LNG:
            case _C_ULNG_LNG:
                lua_pushinteger(L, [object longValue]);
                break;
            default:
                return NO;
        }
    }
    else if( [object isKindOfClass:[NSArray class]] ) {
        lua_newtable(L);
        [object enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
            UkePushObject(L, item);
            lua_rawseti(L, -2, (int)idx + 1); // lua arrays start at 1, not 0
        }];
    }
    else if( [object isKindOfClass:[NSDictionary class]] ) {
        lua_newtable(L);
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            UkePushObject(L, key);
            UkePushObject(L, obj);
            lua_rawset(L, -3);
        }];
    }
    else {
        UkeLuaBridgeObject *wrapper = lua_newuserdata(L, sizeof(UkeLuaBridgeObject));
        luaL_setmetatable(L, METATABLE_NAME);
        wrapper->objPtr = (void *)CFBridgingRetain(object);
    }
    return YES;
}

id UkeToobject(lua_State *L, int idx) {
    switch (lua_type(L, idx)) {
        case LUA_TNIL:
            return nil;
        case LUA_TNUMBER:
            return @(lua_tonumber(L, idx));
        case LUA_TBOOLEAN:
            return @(lua_toboolean(L, idx));
        case LUA_TSTRING:
            return [NSString stringWithUTF8String:lua_tostring(L, idx)];
        case LUA_TTABLE: {
            BOOL isDict = NO;

            lua_pushvalue(L, idx); // make sure the table is at the top
            lua_pushnil(L);  /* first key */
            while( ! isDict && lua_next(L, -2) ) {
                if( lua_type(L, -2) != LUA_TNUMBER ) {
                    isDict = YES;
                    lua_pop(L, 2); // pop key and value off the stack
                }
                else {
                    lua_pop(L, 1);
                }
            }

            id result = nil;

            if( isDict ) {
                result = [NSMutableDictionary dictionary];
                
                lua_pushnil(L);  /* first key */
                while( lua_next(L, -2) ) {
                    id key = UkeToobject(L, -2);
                    id object = UkeToobject(L, -1);
                    if( ! key )
                        continue;
                    if( ! object )
                        object = [NSNull null];
                    result[key] = object;
                    lua_pop(L, 1); // pop the value off
                }
            }
            else {
                result = [NSMutableArray array];
                
                lua_pushnil(L);  /* first key */
                while( lua_next(L, -2) ) {
                    int index = lua_tonumber(L, -2) - 1;
                    id object = UkeToobject(L, -1);
                    if( ! object )
                        object = [NSNull null];
                    result[index] = object;
                    lua_pop(L, 1);
                }
            }
              
            lua_pop(L, 1); // pop the table off
            return result;
        }
        case LUA_TUSERDATA: {
            UkeLuaBridgeObject *wrapper = luaL_checkudata(L, idx, METATABLE_NAME);
            return wrapper ? (__bridge id)wrapper->objPtr : nil;
        }
        case LUA_TFUNCTION:
        case LUA_TTHREAD:
        case LUA_TLIGHTUSERDATA:
        default:
            return nil;
    }
}

int UkeRequireLuaFile(lua_State *L) {
    const char *modname = luaL_checkstring(L, 1);
    NSString *path = [[NSBundle bundleForClass:UkeEngine.class] pathForResource:[NSString stringWithUTF8String:modname] ofType:@"lua"];
    if (!path) return luaL_error(L, "Couldn't find '%s' lua module to require", modname);
    UkeAddLuaPath(L, [path stringByDeletingLastPathComponent]);
    if (luaL_dofile(L, path.UTF8String) != LUA_OK) return lua_error(L);
    return 1;
}

int UkeAddLuaPath(lua_State *L, NSString *path) {
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "path"); // get field "path" from table at top of stack (-1)
    NSString * cur_path = [NSString stringWithUTF8String:lua_tostring(L, -1)]; // grab path string from top of stack
    cur_path = [cur_path stringByAppendingFormat:@";%@/?.lua", path]; // do your path magic here
    lua_pop(L, 1); // get rid of the string on the stack we just pushed on line 5
    lua_pushstring(L, [cur_path UTF8String]); // push the new one
    lua_setfield(L, -2, "path"); // set the field "path" in table at -2 with value at top of stack
    lua_pop(L, 1); // get rid of package table from top of stack
    return 0; // all done!
}

//
//  UkeLuaBridge.h
//  UkeLua
//
//  Created by Gil on 1/16/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lua.h"

void UkeRegisterMetatable(lua_State *L);
BOOL UkePushObject(lua_State *L, id object);
id UkeToobject(lua_State *L, int idx);
int UkeRequireLuaFile(lua_State *L);
int UkeAddLuaPath(lua_State *L, NSString *path);

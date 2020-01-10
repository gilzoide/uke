//
//  UkeParser.h
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UkeView, UkeObjectRecipe;

NS_ASSUME_NONNULL_BEGIN

@interface UkeParser : NSObject

- (nullable UkeObjectRecipe *)recipeWithContents:(const char *)contents;

@end

NS_ASSUME_NONNULL_END

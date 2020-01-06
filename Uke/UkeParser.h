//
//  UkeParser.h
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UkeView;

NS_ASSUME_NONNULL_BEGIN

@interface UkeParser : NSObject

- (int)read:(const char *)contents into:(UkeView *)view;

@end

NS_ASSUME_NONNULL_END

//
//  UkeParser.m
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import "UkeParser.h"

#import "pega-texto.h"
#import "pega-texto/macro-on.h"

#import <Uke/Uke-Swift.h>

pt_data _number(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSNumber *number = [NSNumber numberWithDouble:strtod(str, NULL)];
    return (pt_data){ .p = (void *)CFBridgingRetain(number) };
}
pt_data _keyPath(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSString *keyPath = [[NSString alloc] initWithBytes:str length:size encoding:NSASCIIStringEncoding];
    return (pt_data){ .p = (void *)CFBridgingRetain(keyPath) };
}
pt_data _attribute(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    UkeView *view = (__bridge UkeView *)userdata;
    NSString *keyPath = CFBridgingRelease(argv[0].p);
    id value = CFBridgingRelease(argv[1].p);
    [view setValue:value forKeyPath:keyPath];
    return PT_NULL_DATA;
}

@implementation UkeParser {
    pt_grammar _grammar;
}

- (instancetype)init {
    if (self = [super init]) {
        [UkeParser initGrammar:&_grammar];
    }
    return self;
}

/**
 * Axiom <- \s* (Expr \s*)+ !.
 * Expr <- Attr  # TODO
 * Attr <- Keypath '=' Value
 * Keypath <- Identifier ('.' Identifier)*
 * Identifier <- \a+
 * Value <- Number  # TODO
 * Number <- \d+
 */
+ (void)initGrammar:(pt_grammar *)grammar {
#define Sp Q(C(PT_SPACE), 0)
    pt_rule R[] = {
        { "Axiom", SEQ(Sp, // \s*
                       Q(SEQ(V("Expr"), Sp), 1), // (Expression \s*)+
                       B('\0') // \0
                       ) },
        { "Expr", V("Attr") },
        { "Attr", SEQ_(_attribute, V("Keypath"), Sp, B('='), Sp, V("Value")) },
        { "Keypath", SEQ_(_keyPath,
                          V("Identifier"), // Identifier
                          Q(SEQ(B('.'), V("Identifier")), 0) // ('.' Identifier)*
                          ) },
        { "Identifier", Q(C(PT_ALPHA), 1) },
        { "Value", V("Number") },
        { "Number", Q_(_number, C(PT_DIGIT), 1) },
        { NULL, NULL }
    };
#undef Sp
    pt_init_grammar(grammar, R, 0);
    pt_validate_grammar(grammar, PT_VALIDATE_ABORT);
}

- (int)read:(const char *)contents into:(UkeView *)view {
    pt_match_options opts = { .userdata = (__bridge void *)view };
    pt_match_result result = pt_match_grammar(&_grammar, contents, &opts);
    return result.matched;
}

@end

//
//  UkeParser.m
//  Uke
//
//  Created by Gil on 1/5/20.
//  Copyright © 2020 Gil. All rights reserved.
//

#import "UkeParser.h"
#import "UkeObjectRecipe.h"

#import "pega-texto.h"
#import "pega-texto/macro-on.h"

#import <Uke/Uke-Swift.h>

static inline double _floatOr255BasedInt(double x) {
    return x <= 1 ? x : x / 255.0;
}

pt_data _keyPath(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSString *keyPath = [[NSString alloc] initWithBytes:str length:size encoding:NSASCIIStringEncoding];
    return (pt_data){ .p = (void *)CFBridgingRetain(keyPath) };
}
pt_data _attribute(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    assert(argc == 2 && "Must have both keyPath and value for setting");
    UkeObjectRecipe *recipe = (__bridge UkeObjectRecipe *)userdata;
    NSString *keyPath = CFBridgingRelease(argv[0].p);
    id value = CFBridgingRelease(argv[1].p);
    [recipe addConstant:value forKeyPath:keyPath];
    return PT_NULL_DATA;
}
pt_data _number(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSNumber *number = [NSNumber numberWithDouble:strtod(str, NULL)];
    return (pt_data){ .p = (void *)CFBridgingRetain(number) };
}
pt_data _double(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    return (pt_data){ .d = strtod(str, NULL) };
}
pt_data _numberPairOrQuartet(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    if (argc != 2 && argc != 4) return PT_NULL_DATA;
    CGFloat doubles[4] = { argv[0].d, argv[1].d };
    const char *objCType;
    if (argc == 4) {
        doubles[2] = argv[2].d;
        doubles[3] = argv[3].d;
        objCType = @encode(CGRect);
    }
    else {
        objCType = @encode(CGPoint);
    }
    
    NSValue *value = [NSValue valueWithBytes:doubles objCType:objCType];
    return (pt_data){ .p = (void *)CFBridgingRetain(value) };
}
pt_data _colorWithIdentifier(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSString *identifier = [[NSString alloc] initWithBytes:str length:size encoding:NSASCIIStringEncoding];
    UIColor *color = [UIColor colorWithSelectorName:identifier];
    return (pt_data){ .p = (void *)CFBridgingRetain(color) };
}
pt_data _colorWithHexa(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSString *hexaString = [[NSString alloc] initWithBytes:str length:size encoding:NSASCIIStringEncoding];
    UIColor *color = [UIColor colorWithHexaString:hexaString];
    return (pt_data){ .p = (void *)CFBridgingRetain(color) };
}
pt_data _colorWithRGBA(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    double r = _floatOr255BasedInt(argv[0].d);
    double g = argc > 1 ? _floatOr255BasedInt(argv[1].d) : 0;
    double b = argc > 2 ? _floatOr255BasedInt(argv[2].d) : 0;
    double a = argc > 3 ? _floatOr255BasedInt(argv[3].d) : 1;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    return (pt_data){ .p = (void *)CFBridgingRetain(color) };
}
pt_data _image(const char *str, size_t size, int argc, pt_data *argv, void *userdata) {
    NSString *imageName = [[NSString alloc] initWithBytes:str length:size encoding:NSASCIIStringEncoding];
    imageName = [imageName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    UIImage *image = [UIImage imageNamed:imageName];
    if (@available(iOS 13, macCatalyst 13, *)) {
        if (!image) image = [UIImage systemImageNamed:imageName];
    }
    return (pt_data){ .p = (void *)CFBridgingRetain(image) };
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
 * Value <- Number / NumberPairOrQuartet / Color / Image / Array  # TODO
 * Number <- \d+ ('.' \d+)?
 * NumberPairOrQuartet <- NumberComposite
 * NumberComposite <- '{' Number (',' Number){-3} '}'
 * Color <- 'C' ('#' \x\x\x\x\x\x / Identifier)
 * Image <- 'I' [^\n]+
 * Array <- '[' Value (',' Value) ','? ']'
 */
+ (void)initGrammar:(pt_grammar *)grammar {
#define Sp Q(C(PT_SPACE), 0)
#define Hex C(PT_XDIGIT)
#define Digits Q(C(PT_DIGIT), 1)
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
        { "Value", OR(V("Number"), V("NumberPairOrQuartet"), V("Color"), V("Image")) },
        { "Number", SEQ_(_number, Digits, // \d+
                                  Q(SEQ(B('.'), Digits), -1) // ('.' \d+)?
                         ) },
        { "NumberPairOrQuartet", V_(_numberPairOrQuartet, "NumberComposite") },
        { "NumberComposite", SEQ(B('{'),
                                        V_(_double, "Number"),
                                        Q(SEQ(B(','), V_(_double, "Number")), -3), // (',' Number){-3}
                                 B('}')
                                 ) },
        { "Color", SEQ(B('C'), OR(SEQ_(_colorWithHexa, Hex, Hex, Hex, Hex, Hex, Hex),
                                  V_(_colorWithIdentifier, "Identifier"),
                                  V_(_colorWithRGBA, "NumberComposite"))) },
        { "Image", SEQ(B('I'), Q_(_image, BUT(B('\n')), 1)) },
        { NULL, NULL }
    };
#undef Sp
#undef Hex
    pt_init_grammar(grammar, R, 0);
    pt_validate_grammar(grammar, PT_VALIDATE_ABORT);
}

- (nullable UkeObjectRecipe *)recipeWithContents:(const char *)contents {
    UkeObjectRecipe *recipe = [[UkeObjectRecipe alloc] initWithBaseClass:UkeView.class];
    pt_match_options opts = { .userdata = (__bridge void *)recipe };
    pt_match_result result = pt_match_grammar(&_grammar, contents, &opts);
    return result.matched > 0 ? recipe : nil;
}

@end

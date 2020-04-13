//
//  UIFont+DefaultFont.m
//  Vidacle
//
//  Created by Jacco Taal on 14-01-14.
//  Copyright (c) 2014 Jacco Taal. All rights reserved.
//

@import ObjectiveC;

#import "UIFont+DefaultFont.h"

static NSString * _kDefaultFontFamily;
static NSString * _kDefaultItalicFontFamily;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"


@implementation UIFont (DefaultFont)

void replaceClassSelector(Class class,
                          SEL originalSelector,
                          SEL modifiedSelector);

void replaceInstanceSelector(Class class,
                             SEL originalSelector,
                             SEL modifiedSelector);


+ (void)setupDefaultFontFamily:(NSString*) family {
    _kDefaultFontFamily = family;
    _kDefaultItalicFontFamily = family;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = self;

        replaceClassSelector(class,
                             @selector(systemFontOfSize:),
                             @selector(custom_systemFontOfSize:));

        replaceClassSelector(class,
                             @selector(systemFontOfSize:weight:),
                             @selector(custom_systemFontOfSize:weight:));

        replaceClassSelector(class,
                             @selector(boldSystemFontOfSize:),
                             @selector(custom_boldSystemFontOfSize:));

        replaceClassSelector(class,
                             @selector(italicSystemFontOfSize:),
                             @selector(custom_italicSystemFontOfSize:));

        replaceClassSelector(class,
                             @selector(boldItalicSystemFontOfSize:),
                             @selector(custom_boldItalicSystemFontOfSize:));


        replaceInstanceSelector(class,
                                @selector(initWithCoder:),
                                @selector(custom_initWithCoder:));

        replaceClassSelector(class,
                             @selector(fontWithDescriptor:size:),
                             @selector(custom_fontWithDescriptor:size:));

//        replaceClassSelector(class,
//                             @selector(fontWithName:size:),
//                             @selector(custom_fontWithName:size:));

/*        if ([[Environment dtap] isEqualToString:@"development"]) {
            NSLog(@"Registered Font families: \n%@", [[UIFont familyNames] componentsJoinedByString:@"\n -"]);
            for (NSString * family in [UIFont familyNames]) {
                NSLog(@"Fonts for family %@: %@", family, [[UIFont fontNamesForFamilyName:family] componentsJoinedByString:@"\n -- "]);
            }
        }
 */
    });
}

+ (UIFont *)custom_systemFontOfSize:(CGFloat)fontSize {
    UIFontDescriptor * fontd = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                @{UIFontDescriptorFamilyAttribute:_kDefaultFontFamily,
                                  UIFontDescriptorTraitsAttribute:@{ UIFontWeightTrait:@(UIFontWeightRegular)},
                                  UIFontDescriptorSizeAttribute: @(fontSize)}];
    return [UIFont fontWithDescriptor:fontd size:fontSize];
        //return [UIFont fontWithName:kDefaultFontName size:size];
}

+(UIFont *)custom_systemFontOfSize:(CGFloat)fontSize weight:(CGFloat)weight {
    UIFontDescriptor * fontd = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                @{UIFontDescriptorFamilyAttribute:_kDefaultFontFamily,
                                  UIFontDescriptorTraitsAttribute:@{ UIFontWeightTrait:@(weight)},
                                  UIFontDescriptorSizeAttribute: @(fontSize)}];
    return [UIFont fontWithDescriptor:fontd size:fontSize];
}

+ (UIFont *)custom_boldSystemFontOfSize:(CGFloat)fontSize;
{
    UIFontDescriptor * fontd = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                @{UIFontDescriptorFamilyAttribute:_kDefaultFontFamily,
                                  UIFontDescriptorTraitsAttribute:@{ UIFontWeightTrait:@(UIFontWeightBold)},
                                  UIFontDescriptorSizeAttribute: @(fontSize)}];
    return [UIFont fontWithDescriptor:fontd size:fontSize];

}


+ (UIFont *)custom_italicSystemFontOfSize:(CGFloat)fontSize {
    UIFontDescriptor * fontd = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                @{UIFontDescriptorFamilyAttribute:_kDefaultItalicFontFamily,
                                  UIFontDescriptorTraitsAttribute:@{ UIFontSymbolicTrait:@(UIFontDescriptorTraitItalic)},
                                  UIFontDescriptorSizeAttribute: @(fontSize)}];
    return [UIFont fontWithDescriptor:fontd size:fontSize];
}


+ (UIFont *)custom_boldItalicSystemFontOfSize:(CGFloat)fontSize {
    UIFontDescriptor * fontd = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                @{UIFontDescriptorFamilyAttribute:_kDefaultItalicFontFamily,
                                  UIFontDescriptorTraitsAttribute:@{  UIFontWeightTrait:@(UIFontWeightBold),
                                                                      UIFontSymbolicTrait:@(UIFontDescriptorTraitItalic)},
                                  UIFontDescriptorSizeAttribute: @(fontSize)}];
    return [UIFont fontWithDescriptor:fontd size:fontSize];
}

- (instancetype)custom_initWithCoder:(NSCoder *)aDecoder {
    NSString * const kDescriptorKey = @"UIFontDescriptor";

    BOOL result = [aDecoder containsValueForKey:kDescriptorKey];

    if (result) {
        UIFontDescriptor *descriptor =
            [aDecoder decodeObjectForKey:kDescriptorKey];
            //      NSLog(@"descriptor %@", descriptor);
        NSString * usage = descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"];
        NSMutableDictionary * traits = [descriptor.fontAttributes[UIFontDescriptorTraitsAttribute] mutableCopy];
        if (usage) {

            descriptor =
            [UIFontDescriptor fontDescriptorWithFontAttributes:
             [UIFont attributesForUsage:usage size:descriptor.pointSize
                                 traits:traits]];
        }        // if (descriptor)
                    //   return [UIFont fontWithDescriptor:descriptor size:descriptor.pointSize];
                    //    NSLog(@"descriptor %@", descriptor);
        NSMutableData * data = [NSMutableData new];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:descriptor forKey:kDescriptorKey];
        [archiver finishEncoding];

        return [self custom_initWithCoder:[[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithData: data ]] ];
            //
            // return [UIFont fontWithDescriptor:descriptor size:descriptor.pointSize];
            //[aDecoder encodeObject:descriptor forKey:@"UIFontDescriptor"];
    }


    UIFont * font = [self custom_initWithCoder:aDecoder]; // swizzled method
                                                          //    NSLog(@"Font: %@, %@", font, font.fontDescriptor);
    return font;
}

+(instancetype)custom_fontWithDescriptor:(UIFontDescriptor*)descriptor size:(CGFloat) size {
    NSString * usage = descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"];
    if (usage) {
        UIFontDescriptor * descriptor =  [UIFontDescriptor fontDescriptorWithFontAttributes:
                                          [self attributesForUsage:usage size:size traits:0]];

        UIFont * font = [self custom_fontWithDescriptor:descriptor
                                                   size:size];
        return font;
    }
    return [self custom_fontWithDescriptor:descriptor
                                      size:size];
}

+(NSDictionary*)attributesForUsage:(NSString*)usage
                              size:(CGFloat)size
                            traits:(NSDictionary*) traits {
    NSString * familyName = _kDefaultFontFamily;

    NSMutableDictionary * _traits = [NSMutableDictionary dictionaryWithDictionary:traits?traits:@{}];
    CGFloat weight = UIFontWeightRegular;
    CGFloat prefSize = 0;
    prefSize = 14.0;

    if ([usage isEqualToString:@"CTFontRegularUsage"]) {
        weight = UIFontWeightRegular;
    } else if ([usage isEqualToString:@"CTFontEmphasizedUsage"]) {
        weight = UIFontWeightSemibold;

    } else if ([usage isEqualToString:@"CTFontObliqueUsage"]) {
        _traits[UIFontSymbolicTrait] = @(UIFontDescriptorTraitItalic);
            // italic
        familyName = _kDefaultItalicFontFamily;
    } else if ([usage isEqualToString:@"CTFontHeavyUsage"]) {
        weight = UIFontWeightHeavy;
    } else if ([usage isEqualToString:@"CTFontUltraLightUsage"]) {
        weight = UIFontWeightUltraLight;
    } else if ([usage isEqualToString:@"CTFontLightUsage"]) {
        weight = UIFontWeightLight;
    } else if ([usage isEqualToString:@"CTFontMediumUsage"]) {
        weight = UIFontWeightMedium;
    } else if ([usage isEqualToString:@"CTFontThinUsage"]) {
        weight = UIFontWeightThin;
    } else if ([usage isEqualToString:@"UICTFontTextStyleHeadline"]){
        weight = UIFontWeightSemibold;
        prefSize = 18.0;
    } else if ([usage isEqualToString:@"UICTFontTextStyleShortFootnote"]) {
        weight = UIFontWeightSemibold;
        prefSize = 12.0;
    } else if ([usage isEqualToString:@"UICTFontTextStyleShortBody"]) {
        weight = UIFontWeightSemibold;
        prefSize = 13.0;
    } else if ([usage isEqualToString:@"CTFontBoldUsage"]) {
        weight = UIFontWeightBold;
    } else if ([usage isEqualToString:@"CTFontDemiUsage"]) {
        weight = UIFontWeightMedium;
    } else if ([usage isEqualToString:@"CTFontSystemUIAlternateRegular"]) {
        weight = UIFontWeightRegular;
    } else if ([usage isEqualToString:@"CTFontTextStyleShortEmphasizedBody"]) {
        weight = UIFontWeightMedium;
    } else if ([usage isEqualToString:@"UICTFontTextStyleEmphasizedTitle"]) {
        weight = UIFontWeightSemibold;
        prefSize = 14.0;
    } else if ([usage isEqualToString:@"UICTFontTextStyleBody"]) {
        weight = UIFontWeightRegular;
    } else if ([usage isEqualToString:@"UICTFontTextStyleEmphasizedTitle0"]) {
        weight = UIFontWeightBold;
    } else if ([usage isEqualToString:@"UICTFontTextStyleFootnote"]) {
        weight = UIFontWeightMedium;
        prefSize = 10.0;
    } else if ([usage isEqualToString:@"UICTFontTextStyleEmphasizedBody"]) {
        weight = UIFontWeightMedium;
    } else if ([usage isEqualToString:@"UICTFontTextStyleShortEmphasizedBody"]) {
        weight = UIFontWeightMedium;
    } else {
        NSLog(@"unknown font usage: %@", usage);

    }
    if (size == 0.0)
        size = prefSize;

    _traits[UIFontWeightTrait] = @(weight);

    if (familyName) {
        return  @{UIFontDescriptorSizeAttribute: @(size),
                  UIFontDescriptorFamilyAttribute: familyName,
                  UIFontDescriptorTraitsAttribute:_traits?_traits:@{}
                  };
    }

    return nil;
}

//+(instancetype)custom_fontWithName:(NSString*)name size:(CGFloat)size {
//    return [self fontWithName:name size:size traits:0];
//}


+(instancetype)custom_fontWithName:(NSString*)name size:(CGFloat)size traits:(int) traits{
    UIFont * font = [self custom_fontWithName:name size:size traits:traits];

    UIFontDescriptor * descriptor = font.fontDescriptor;

    NSString * usage = descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"];


    if (!usage)
        return font;

    NSMutableDictionary * _traits = [descriptor.fontAttributes[UIFontDescriptorTraitsAttribute] mutableCopy];

    descriptor =
    [descriptor fontDescriptorByAddingAttributes:[self attributesForUsage:usage size:size traits:_traits]];
    if (descriptor)
        return [UIFont fontWithDescriptor:descriptor
                                     size:descriptor.pointSize];
    return font;
}




+(UIFont *)custom_preferredFontForTextStyle:(NSString *)style {

    UIFontDescriptor * fd = [UIFontDescriptor preferredFontDescriptorWithTextStyle:style];

    return [UIFont fontWithDescriptor:fd size:fd.pointSize];
}

#pragma clang diagnostic pop


@end


@implementation UIFontDescriptor (DefaultFont)

+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        replaceClassSelector([UIFontDescriptor class],
                             @selector(preferredFontDescriptorWithTextStyle:),
                             @selector(custom_preferredFontDescriptorWithTextStyle:));
    });
}


+(UIFontDescriptor*)custom_preferredFontDescriptorWithTextStyle:(NSString*)style {
    UIFontDescriptor * fd = [self custom_preferredFontDescriptorWithTextStyle:style];

    NSString * fontFamily = _kDefaultFontFamily;

    CGFloat weight = UIFontWeightRegular;
        //CGFloat size;

    NSMutableDictionary * traits = [fd.fontAttributes[UIFontDescriptorTraitsAttribute] mutableCopy];
    CGFloat size = fd.pointSize;

    NSNumber * _w = traits[UIFontWeightTrait];
    if (_w)
        weight = _w.floatValue;

    if ([style isEqualToString: UIFontTextStyleHeadline]) {
        weight = UIFontWeightSemibold;
            //      size = 18.0;
    } else if([style isEqualToString: UIFontTextStyleSubheadline]) {
        weight = UIFontWeightSemibold;
            //   size = 15.0;
    } else if ([style isEqualToString: UIFontTextStyleBody]) {
            //    size = 13.0;
    } else if ([ style isEqualToString: UIFontTextStyleFootnote]) {
        weight = UIFontWeightSemibold;
            //   size = 12.0;
    } else if ([style isEqualToString:UIFontTextStyleCaption1]) {
        weight = UIFontWeightSemibold;
            //   size = 13.0;
    } else if ([style isEqualToString: UIFontTextStyleCaption2]) {
            //   size = 13.0;
    } else {
        NSLog(@"Unknown style: %@", style);
    }

    if (!traits)
        traits = [NSMutableDictionary new];
    traits[UIFontWeightTrait] = @(weight);

    UIFontDescriptor *fdnew = [UIFontDescriptor fontDescriptorWithFontAttributes:
                               @{UIFontDescriptorFamilyAttribute: fontFamily,
                                 UIFontDescriptorTraitsAttribute:traits?traits:@{},
                                 UIFontDescriptorSizeAttribute: @(size?size:14.0)
                                 }
                               ];
    return fdnew;
}

@end

void replaceClassSelector(Class class,
                          SEL originalSelector,
                          SEL modifiedSelector) {
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method modifiedMethod = class_getClassMethod(class, modifiedSelector);
    method_exchangeImplementations(originalMethod, modifiedMethod);
}


void replaceInstanceSelector( Class class,
                             SEL originalSelector,
                             SEL modifiedSelector) {
    Method originalDecoderMethod =
    class_getInstanceMethod(class, originalSelector);
    Method modifiedDecoderMethod =
    class_getInstanceMethod(class, modifiedSelector);
    method_exchangeImplementations(originalDecoderMethod,
                                   modifiedDecoderMethod);
}

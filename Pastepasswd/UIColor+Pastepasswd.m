//
//  UIColor+Pastepasswd.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 7/19/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "UIColor+Pastepasswd.h"

@implementation UIColor (Pastepasswd)

+ (UIColor *)pastepasswdMainColor {
    return  [self colorWithHue:0.48 saturation:0.64 brightness:0.76 alpha:1.00];
}

+ (UIColor *)pastepasswdTextColor {
    return [self colorWithRed:124.0f / 255.0f green:137.0f / 255.0f blue:147.0f / 255.0f alpha:1.0f];
}

@end

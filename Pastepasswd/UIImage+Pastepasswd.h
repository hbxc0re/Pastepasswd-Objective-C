//
//  UIImage+Pastepasswd.h
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Pastepasswd)

+ (UIImage *)imageWithColor:(UIColor *)color
               cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *) buttonImageWithColor:(UIColor *)color
                      cornerRadius:(CGFloat)cornerRadius
                       shadowColor:(UIColor *)shadowColor
                      shadowInsets:(UIEdgeInsets)shadowInsets;

+ (UIImage *) circularImageWithColor:(UIColor *)color
                                size:(CGSize)size;

- (UIImage *) imageWithMinimumSize:(CGSize)size;

+ (UIImage *) stepperPlusImageWithColor:(UIColor *)color;
+ (UIImage *) stepperMinusImageWithColor:(UIColor *)color;

+ (UIImage *) backButtonImageWithColor:(UIColor *)color
                            barMetrics:(UIBarMetrics) metrics
                          cornerRadius:(CGFloat)cornerRadius;

@end

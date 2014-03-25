//
//  UIProgressView+Pastepasswd.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "UIProgressView+Pastepasswd.h"
#import "UIImage+Pastepasswd.h"

@implementation UIProgressView (Pastepasswd)

- (void)configureFlatProgressViewWithTrackColor:(UIColor *)trackColor {
    UIImage *trackImage = [UIImage imageWithColor:trackColor cornerRadius:4.0];
    trackImage = [trackImage imageWithMinimumSize:CGSizeMake(10.0f, 10.0f)];
    [self setTrackImage:trackImage];
}

- (void)configureFlatProgressViewWithProgressColor:(UIColor *)progressColor {
    UIImage *progressImage = [UIImage imageWithColor:progressColor cornerRadius:4.0];
    [self setProgressImage:progressImage];
}

- (void) configureFlatProgressViewWithTrackColor:(UIColor *)trackColor
                                   progressColor:(UIColor *)progressColor {
    [self configureFlatProgressViewWithTrackColor:trackColor];
    [self configureFlatProgressViewWithProgressColor:progressColor];
}

@end

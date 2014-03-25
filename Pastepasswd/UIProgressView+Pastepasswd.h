//
//  UIProgressView+Pastepasswd.h
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/24/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIProgressView (Pastepasswd)

- (void)configureFlatProgressViewWithTrackColor:(UIColor *)trackColor; UI_APPEARANCE_SELECTOR
- (void)configureFlatProgressViewWithProgressColor:(UIColor *)progressColor; UI_APPEARANCE_SELECTOR

- (void) configureFlatProgressViewWithTrackColor:(UIColor *)trackColor
                                   progressColor:(UIColor *)progressColor;

@end

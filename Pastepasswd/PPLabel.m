//
//  PPLabel.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 2/17/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPLabel.h"

#import <CoreText/CoreText.h>

#pragma mark - Private Interface

@interface PPLabel ()
- (void)_setup;
@end

@implementation PPLabel

#pragma mark - Accessors

@synthesize verticalAlignment = _verticalAlignment;
@synthesize insets = _insets;

- (void)setVerticalAlignment:(LabelVerticalAlignment)verticalAlignment
{
    _verticalAlignment = verticalAlignment;
    [self setNeedsLayout];
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    [self setNeedsLayout];
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [self _setup];
    }
    
    return self;
}

#pragma mark - UILabel

- (void)drawTextInRect:(CGRect)rect
{
    rect = UIEdgeInsetsInsetRect(rect, _insets);
    
    if (self.verticalAlignment == LabelVerticalAlignmentTop)
    {
        CGSize sizeThatFits = [self sizeThatFits:rect.size];
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, sizeThatFits.height);
    }
    else if(self.verticalAlignment == LabelVerticalAlignmentBottom)
    {
        CGSize sizeThatFits = [self sizeThatFits:rect.size];
        rect = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - sizeThatFits.height), rect.size.width, sizeThatFits.height);
    }
    
    [super drawTextInRect:rect];
}

#pragma mark - Private Implementation

- (void)_setup
{
    self.verticalAlignment = LabelVerticalAlignmentCenter;
    self.insets = UIEdgeInsetsZero;
}

@end




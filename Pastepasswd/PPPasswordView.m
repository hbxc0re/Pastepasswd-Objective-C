//
//  PPPasswordView.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/31/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPPasswordView.h"
#import "TTTAttributedLabel.h"

@interface PPPasswordView ()

@end

@implementation PPPasswordView

@synthesize passwordSecureLabel = _passwordSecureLabel;
@synthesize normalTextContainer = _normalTextContainer;
@synthesize secureTextContainer = _secureTextContainer;
@synthesize attributedLabel = _attributedLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 
        _normalTextContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, [[self class] height])];
        _normalTextContainer.backgroundColor = [UIColor colorWithRed:246.0 / 255.0f green:246.0f / 255.0f blue:246.0f / 255.0f alpha:1.0f];

        [self addSubview:_normalTextContainer];
        
        _secureTextContainer = [[UIView alloc] initWithFrame:CGRectMake(320.0f, 0.0f, self.frame.size.width, [[self class] height])];
        _secureTextContainer.backgroundColor = [UIColor colorWithRed:235.0 / 255.0f green:89.0f / 255.0f blue:89.0f / 255.0f alpha:1.0f];
        [self addSubview:_secureTextContainer];
        
        _attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, [[self class] height])];
        _attributedLabel.textColor = [UIColor colorWithRed:133.0f / 255.0f green:155.0f / 255.0f blue:172.0f / 255.0f alpha:1.0];
        _attributedLabel.backgroundColor = [UIColor clearColor];
        _attributedLabel.numberOfLines = 0;
        _attributedLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
        _attributedLabel.textAlignment = NSTextAlignmentCenter;
        //_attributedLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        [_normalTextContainer addSubview:_attributedLabel];
        
        _passwordSecureLabel = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, [[self class] height])];
        _passwordSecureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _passwordSecureLabel.backgroundColor = [UIColor clearColor];
        _passwordSecureLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
        _passwordSecureLabel.textAlignment = NSTextAlignmentCenter;
        _passwordSecureLabel.textColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
        _passwordSecureLabel.secureTextEntry = YES;
        [_secureTextContainer addSubview:_passwordSecureLabel];
    }
    return self;
}

+ (CGFloat)height {
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    if (result.height == 480) {
        return 50.0f;
    } else if (result.height == 568) {
        return 54.0f;
    }
    
    return 0.0f;
}

- (void)slideOut {
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        _normalTextContainer.frame = CGRectMake(-self.bounds.size.width, 0.0f, self.bounds.size.width, 65);
        _secureTextContainer.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 65);
    } completion:nil];
}

- (void)slideIn {
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        _normalTextContainer.frame = CGRectMake(0.0, 0.0f, self.bounds.size.width, 65);
        _secureTextContainer.frame = CGRectMake(self.bounds.size.width, 0.0f, self.bounds.size.width, 65);
    } completion:nil];
}


@end

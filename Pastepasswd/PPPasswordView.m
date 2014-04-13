//
//  PPPasswordView.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 3/31/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPPasswordView.h"

@interface PPPasswordView ()

@end

@implementation PPPasswordView

@synthesize passwordLabel = _passwordLabel;
@synthesize passwordSecureLabel = _passwordSecureLabel;
@synthesize normalTextContainer = _normalTextContainer;
@synthesize secureTextContainer = _secureTextContainer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.backgroundColor = [UIColor colorWithRed:246.0f / 255.0f green:115.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f];
        
        _normalTextContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 65.0f)];
        _normalTextContainer.backgroundColor = [UIColor whiteColor];
        [self addSubview:_normalTextContainer];
        
        _secureTextContainer = [[UIView alloc] initWithFrame:CGRectMake(320.0f, 0.0f, self.frame.size.width, 65.0f)];
        _secureTextContainer.backgroundColor = [UIColor colorWithRed:245.0 / 255.0f green:107.0f / 255.0f blue:94.0f / 255.0f alpha:1.0f];
        [self addSubview:_secureTextContainer];
        
        _passwordLabel = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 65.0f)];
        _passwordLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _passwordLabel.backgroundColor = [UIColor clearColor];
        _passwordLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        _passwordLabel.textAlignment = NSTextAlignmentCenter;
        _passwordLabel.textColor = [UIColor colorWithRed:54.0f / 255.0f green:66.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
        _passwordLabel.secureTextEntry = NO;
        [_normalTextContainer addSubview:_passwordLabel];
        
        _passwordSecureLabel = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 65.0f)];
        _passwordSecureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _passwordSecureLabel.backgroundColor = [UIColor clearColor];
        _passwordSecureLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        _passwordSecureLabel.textAlignment = NSTextAlignmentCenter;
        _passwordSecureLabel.textColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];
        _passwordSecureLabel.secureTextEntry = YES;
        [_secureTextContainer addSubview:_passwordSecureLabel];

    }
    return self;
}

- (void)slideOut
{
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        _normalTextContainer.frame = CGRectMake(-self.bounds.size.width, 0.0f, self.bounds.size.width, 65);
        _secureTextContainer.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 65);
    } completion:nil];
    
//    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
//        _taskContainerView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
//        _tagsView.frame = CGRectMake(self.bounds.size.width, 0.0f, self.bounds.size.width, self.bounds.size.height);
//    } completion:^(BOOL finished) {
//        [_tagsView removeFromSuperview];
//        _tagsView = nil;
//        
//        [_tagsContainerView removeFromSuperview];
//        _tagsContainerView = nil;
//    }];
}

- (void)slideIn
{
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        _normalTextContainer.frame = CGRectMake(0.0, 0.0f, self.bounds.size.width, 65);
        _secureTextContainer.frame = CGRectMake(self.bounds.size.width, 0.0f, self.bounds.size.width, 65);
    } completion:nil];
}


@end

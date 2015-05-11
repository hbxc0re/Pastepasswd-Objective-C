//
//  PPPastepasswdViewController.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 7/27/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPPastepasswdViewController.h"
#import "PPLabel.h"
#import "UIFont+Pastepasswd.h"

@interface PPPastepasswdViewController ()
- (void)_closeView:(id)sender;
@end

@implementation PPPastepasswdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f)];
    title.accessibilityLabel = @"About";
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
    title.textColor = [UIColor whiteColor];
    title.text = @"About";
    title.layer.shouldRasterize = YES;
    title.clipsToBounds = NO;
    [title sizeToFit];
    
    self.navigationItem.titleView = title;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(_closeView:) forControlEvents:UIControlEventTouchDown];
    [backButton setFrame:CGRectMake(0.0f, 0.0f, 13.0f, 22.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back-view"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back-view"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = backButtonItem;

    NSString *text = @"Version 1.0";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    
    PPLabel *headerVersion = [[PPLabel alloc] initWithFrame:CGRectMake(10.0f, 80.0f, self.view.frame.size.width - 20.0f, 65.0f)];
    headerVersion.numberOfLines = 0;
    headerVersion.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerVersion.backgroundColor = [UIColor clearColor];
    headerVersion.font = [UIFont mediumFontWithSize:14.0f];
    headerVersion.textColor = [UIColor colorWithRed:122.0f / 255.0f green:125.0f / 255.0f blue:133.0f / 255.0f alpha:1.0f];
    headerVersion.text = @"Version 1.0";
    
    headerVersion.attributedText = attributedString;
    headerVersion.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:headerVersion];
}

#pragma mark - Private Implementation

- (void)_closeView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end

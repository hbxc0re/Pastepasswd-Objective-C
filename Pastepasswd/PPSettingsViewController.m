//
//  PPSettingsViewController.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 4/18/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPSettingsViewController.h"
#import "PPSettingsTableViewCell.h"
#import "PPLabel.h"
#import "UIColor+Pastepasswd.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface PPSettingsViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation PPSettingsViewController

#pragma mark - Accessors

#pragma mark - NSObject

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIView *parentView in self.navigationController.navigationBar.subviews)
        for (UIView *childView in parentView.subviews)
            if ([childView isKindOfClass:[UIImageView class]])
                [childView removeFromSuperview];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 24.0f)];
    title.accessibilityLabel = @"Settings";
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
    title.textColor = [UIColor whiteColor];
    title.text = @"Settings";
    title.layer.shouldRasterize = YES;
    title.clipsToBounds = NO;
    [title sizeToFit];

    self.navigationItem.titleView = title;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchDown];
    [doneButton setFrame:CGRectMake(0.0f, 0.0f, 45.0f, 22.0f)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
  
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

#pragma mark - Actions

- (IBAction)close:(id)sender {
    [self.delegate closeSettings];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"None";
    NSUInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    
    if (numberOfRows == 1) {
        cellIdentifier = @"Both";
    }
    else if (indexPath.row == 0) {
        cellIdentifier = @"Top";
    }
    else if (indexPath.row == numberOfRows - 1) {
        cellIdentifier = @"Bottom";
    }
    
    PPSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[PPSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *modeValue = [userDefaults objectForKey:@"mode"];
        
        UISwitch *switchMode = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchMode setOnTintColor:[UIColor pastepasswdMainColor]];
        if ([modeValue isEqualToString:@"2"]) {
            [switchMode setOn:YES animated:YES];
        } else {
            [switchMode setOn:NO animated:YES];
        }
        
        [switchMode addTarget:self action:@selector(_switchMode:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchMode;
        cell.label.text = @"Mode";
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-disclosure"]];
            cell.accessoryView = icon;
            cell.label.text = @"About";
        }
        if (indexPath.row == 1) {
            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-disclosure"]];
            cell.accessoryView = icon;
            cell.label.text = @"Send Feedback";
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 40.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"OPTIONS";
    }
    else if (section == 1)
    {
        return @"MORE";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
           
        }
        return;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            
        }
        else if (indexPath.row == 1)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send Suggestions", @"Request Help", nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
            [actionSheet showInView:self.view];
        }
    }
}

#pragma mark - Private Implementation

- (void)_switchMode:(id)sender
{
    BOOL state = [sender isOn];
    NSString *value = state == YES ? @"2" : @"1";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:@"mode"];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeMode" object:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            if ([MFMailComposeViewController canSendMail])
            {
                [[UINavigationBar appearance] setTintColor:nil];
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"Suggestions"];
                
                NSArray *toRecipients = [NSArray arrayWithObjects:@"support@clipr.io", nil];
                [mailer setToRecipients:toRecipients];
                
                UIFont *font = [UIFont systemFontOfSize:16.0f];
                
                [mailer.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:font}];
                [mailer.navigationBar setTintColor:[UIColor whiteColor]];
                
                [self presentViewController:mailer animated:YES completion:nil];
                
                
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            }
            break;
        case 1:
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"Help"];
                
                NSArray *toRecipients = [NSArray arrayWithObjects:@"help@clipr.io", nil];
                [mailer setToRecipients:toRecipients];
                
                UIFont *font = [UIFont systemFontOfSize:16.0f];
                
                [mailer.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName:font}];
                [mailer.navigationBar setTintColor:[UIColor whiteColor]];
                
                [self presentViewController:mailer animated:YES completion:nil];
                
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"Your device doesn't support the composer sheet"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            }
            
            break;
        default:
            break;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor colorWithRed:64.0f / 255.0f green:66.0f / 255.0f blue:78.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            //NSLog(@"Mail not sent.");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

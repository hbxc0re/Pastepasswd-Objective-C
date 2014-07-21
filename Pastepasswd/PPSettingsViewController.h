//
//  PPSettingsViewController.h
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 4/18/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPGroupedTableViewController.h"

@protocol PPSettingsViewControllerDelegate;

@interface PPSettingsViewController : PPGroupedTableViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<PPSettingsViewControllerDelegate> delegate;

#pragma mark - Actions

- (IBAction)close:(id)sender;

@end

@protocol PPSettingsViewControllerDelegate

- (void)closeSettings;

@end


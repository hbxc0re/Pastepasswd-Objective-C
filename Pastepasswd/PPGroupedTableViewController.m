//
//  PPGroupedTableViewController.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 4/18/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPGroupedTableViewController.h"
#import "PPLabel.h"

@implementation PPGroupedTableViewController
{
    NSCache *_headerCache;
}

#pragma mark - NSObject

- (id)init
{
    return (self = [super initWithStyle:UITableViewStyleGrouped]);
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_headerCache)
    {
        _headerCache = [[NSCache alloc] init];
    }
    
    NSNumber *key = [NSNumber numberWithInteger:section];
    PPLabel *label = [_headerCache objectForKey:key];
    
    if (!label)
    {
        NSString *text = [self tableView:tableView titleForHeaderInSection:section];
        
        if (!text)
        {
            return nil;
        }
        
        label = [[PPLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
        label.insets = UIEdgeInsetsMake(14.0f, 14.0f, 0.0f, 0.0f);
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0f];
        label.text = text;
        [_headerCache setObject:label forKey:key];
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

@end

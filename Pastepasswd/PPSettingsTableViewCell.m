//
//  PPSettingsTableViewCell.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 4/18/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPSettingsTableViewCell.h"
#import "PPLabel.h"
#import "UIColor+Pastepasswd.h"

@implementation PPSettingsTableViewCell

@synthesize label = _label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.hidden = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _label = [[PPLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 20.0f)];
        _label.numberOfLines = 0;
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _label.backgroundColor = [UIColor clearColor];
        [_label setFont: [UIFont fontWithName:@"Avenir-Medium" size:16.0f]];
        _label.textColor = [UIColor pastepasswdTextColor];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = CGRectMake(14.0f, 12.0f, self.frame.size.width, 20.0f);
}

@end

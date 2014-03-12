//
//  PPLabel.h
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 2/17/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

typedef enum
{
    LabelVerticalAlignmentTop = UIControlContentVerticalAlignmentTop,
    LabelVerticalAlignmentCenter = UIControlContentVerticalAlignmentCenter,
    LabelVerticalAlignmentBottom = UIControlContentVerticalAlignmentBottom
} LabelVerticalAlignment;

@interface PPLabel : UILabel

@property (nonatomic, assign) LabelVerticalAlignment verticalAlignment;
@property (nonatomic, assign) UIEdgeInsets insets;

@end

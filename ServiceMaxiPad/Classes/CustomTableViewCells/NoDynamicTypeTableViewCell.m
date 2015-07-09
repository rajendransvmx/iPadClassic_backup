//
//  NoDynamicTypeTableViewCell.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 7/9/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "NoDynamicTypeTableViewCell.h"

@implementation NoDynamicTypeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/* this method defined to preserve cell content after dynamic type size changes. */
- (void)_systemTextSizeChanged
{
    // don't call super!
}


@end

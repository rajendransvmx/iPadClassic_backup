//
//  PartsTableViewCell.m
//  Debriefing
//
//  Created by Sanchay on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PartsTableViewCell.h"


@implementation PartsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc
{
    [super dealloc];
}

#pragma mark LayoutCellSubviews method
- (void) LayoutCellSubviews
{
	
}

@end

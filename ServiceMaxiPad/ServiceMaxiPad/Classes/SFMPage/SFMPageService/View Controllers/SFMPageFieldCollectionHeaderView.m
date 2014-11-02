//
//  SFMPageFieldCollectionHeaderView.m
//  ServiceMaxMobile
//
//  Created by Aparna on 12/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageFieldCollectionHeaderView.h"

@implementation SFMPageFieldCollectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void) layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10, 0, self.frame.size.width, self.frame.size.height);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
}
@end

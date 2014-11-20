//
//  SFMPageHistoryHeaderView.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHistoryHeaderSectionView.h"
#import "TagManager.h"

@implementation SFMPageHistoryHeaderSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _leftTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _leftTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _rightTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:_leftTitle];
        [self addSubview:_rightTitle];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftTitle.frame = CGRectMake(self.bounds.origin.x +10, self.bounds.origin.y, self.bounds.size.width/2,
                                  self.bounds.size.height);
    
    self.rightTitle.frame = CGRectMake(CGRectGetMaxX(self.leftTitle.bounds), self.bounds.origin.y, self.bounds.size.width,
                                       self.bounds.size.height);
    
   // self.leftTitle.textColor = [UIColor grayColor];
    
   // self.rightTitle.textColor = [UIColor grayColor];
}

- (void)setTitleTextForLabel
{
    self.leftTitle.text = [[TagManager sharedInstance] tagByName:kTagServiceReportProblemDescription];
    self.rightTitle.text =  [[TagManager sharedInstance] tagByName:kTagSfmCreatedDate];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

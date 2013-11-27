//
//  DocumentViewCell.m
//  ServiceMaxMobile
//
//  Created by Kirti on 08/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "DocumentViewCell.h"

@implementation DocumentViewCell

@synthesize editIconImageView;
@synthesize cellTypeImageView;
@synthesize titleLabel;
@synthesize subTitleLabel;
@synthesize leftLabel;
@synthesize progessLabel;
@synthesize imageTitleLabel;

- (void)dealloc {
    [editIconImageView release];
    [cellTypeImageView release];
    [titleLabel release];
    [subTitleLabel release];
    [leftLabel release];
    [progessLabel release];
    [imageTitleLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeAndFrameAllSubviews];
    }
    return self;
}

- (void)initializeAndFrameAllSubviews {
    
    CGFloat x = 20,y = 7,cellHeight = 94;
    
//    UIImage *image = [UIImage imageNamed:@"bgDocuments.png"];
//    UIImageView *backGroundView = [[UIImageView alloc] initWithImage:image];
//    backGroundView.frame = CGRectMake(30, 30, 658, 92);
//    backGroundView.backgroundColor = [UIColor clearColor];
//    [self.contentView addSubview:backGroundView];
//    [backGroundView release];
//    backGroundView = nil;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, cellHeight - 57  ,30,30)];
    self.editIconImageView = tempImageView;
    [self.contentView addSubview:tempImageView];
    tempImageView.backgroundColor = [UIColor clearColor];
    [tempImageView release];
    tempImageView = nil;
    
    x  = x + self.editIconImageView.frame.size.width;
    tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y,80,80)];
    self.cellTypeImageView = tempImageView;
    [self.contentView addSubview:tempImageView];
    tempImageView.backgroundColor = [UIColor clearColor];
    [tempImageView release];
    tempImageView = nil;

    
    
    
    UILabel *imageTxt = [[UILabel alloc] initWithFrame:CGRectMake(x, y+51, 80 , 30)];
    self.imageTitleLabel = imageTxt;
    imageTxt.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    imageTxt.backgroundColor = [UIColor clearColor];
    imageTxt.textAlignment  = NSTextAlignmentCenter;
    imageTxt.text = nil;
    imageTxt.numberOfLines = 0;
    imageTxt.textColor =  [UIColor whiteColor];
    [self.contentView addSubview:imageTxt];
    [imageTxt release];
    imageTxt = nil;

    
    x = x + self.cellTypeImageView.frame.size.width + 25;
    y = y + 22;
    
    UILabel *someLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 500 , 30)];
    self.titleLabel = someLabel;
    someLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    someLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:someLabel];
    [someLabel release];
    someLabel = nil;
    
    someLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y - 21, 300 , 20)];
    self.progessLabel = someLabel;
    someLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    someLabel.backgroundColor = [UIColor clearColor];
    someLabel.textColor =  [UIColor blueColor];
    [self.contentView addSubview:someLabel];
    [someLabel release];
    someLabel = nil;
    
    
    
    
    
    y = y + titleLabel.frame.size.height + 5;
    someLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300 , 20)];
    self.subTitleLabel = someLabel;
    someLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    someLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:someLabel];
    [someLabel release];
    someLabel = nil;
    
    
    
    someLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 300 + 40, y, 100 , 20)];
    self.leftLabel = someLabel;
    someLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    someLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:someLabel];
    [someLabel release];
    someLabel = nil;
    
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

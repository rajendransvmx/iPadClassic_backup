//
//  DebriefSectionView.m
//  ServiceMaxMobile
//
//  Created by Sahana on 12/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DebriefSectionView.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"

@interface DebriefSectionView ()

@property (nonatomic, strong) UILabel * detailLabel;
@property (nonatomic, strong) UIImageView *detailImage;


@end

@implementation DebriefSectionView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self populateUi];
        [self addGesture];
        [self addDeatilViewGesture];
    }
    return self;
}

-(void)populateUi
{
    CGFloat width = CGRectGetWidth(self.frame);
    
    self.expandImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sfm_right_arrow.png"]];
    
    self.expandImg.contentMode  = UIViewContentModeScaleAspectFit;
    [self addSubview:self.expandImg];
    
    CGRect imgFrame = self.expandImg.frame;
    
    CGRect labelFrame = CGRectMake(self.frame.origin.x + imgFrame.size.width+ 10 , 0, width-imgFrame.size.width-20,self.frame.size.height);
    self.sectionLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [self addSubview: self.sectionLabel];
    
    self.detailView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.detailLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    self.detailLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
    self.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.detailView addSubview:self.detailLabel];
    
    self.detailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sfm_right_arrow.png"]];
    self.detailImage.contentMode  = UIViewContentModeScaleAspectFit;
    [self.detailView addSubview:self.detailImage];
        
    [self addSubview:self.detailView];
}

-(void)layoutSubviews
{
    CGFloat width = CGRectGetWidth(self.frame);
    
    CGFloat x = self.frame.origin.x + CGRectGetWidth(self.expandImg.frame)/2 + 15;
    CGFloat y =  CGRectGetHeight( self.expandImg.frame)/2+10
    ;
    
    CGRect imageViewFrame ;
    
    imageViewFrame.origin.x = self.bounds.origin.x + 3 ;
    imageViewFrame.origin.y = self.bounds.origin.y + 10;
    imageViewFrame.size.width = 20;//30;
    imageViewFrame.size.height = 20;//26;
    
    self.expandImg.bounds = CGRectMake(0, 0, 20, 20);
    self.expandImg.center = CGPointMake(x, y);
    
    CGRect imgFrame = self.expandImg.frame;
    
    CGRect frame = CGRectMake(0, 0, 200, self.frame.size.height - 10);
    self.detailView.bounds = frame;
    self.detailView.center = CGPointMake(CGRectGetMaxX(self.frame) + 20, y);
    
    
    CGRect labelFrame = CGRectMake(0, 0, width-imgFrame.size.width- frame.size.width + 90,self.frame.size.height);
    self.sectionLabel.bounds = labelFrame;
    self.sectionLabel.center =  CGPointMake( width/2 - 20 , y) ;
    
    self.detailLabel.frame = CGRectMake(0, 0, self.detailView.frame.size.width - 140, self.detailView.bounds.size.height);
    
    CGRect detailImageFrame = CGRectMake(CGRectGetWidth(self.detailLabel.bounds) - 5, self.bounds.origin.y + 10, 20, 20);
    
    self.detailImage.frame = detailImageFrame;
}

-(void)addGesture
{
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionTapped)];
    [self addGestureRecognizer:gesture];
}

- (void)addDeatilViewGesture
{
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailsTapped)];
    [self.detailView addGestureRecognizer:gesture];
}

-(void)detailsTapped
{
    [self.delegate detailTapped:self];
}

-(void)sectionTapped
{
    [self.delegate sectionTapped:self];
}
-(void)setExpandImage:(BOOL)expand
{
    UIImage * img = (expand)?[UIImage imageNamed:@"sfm_down_arrow.png"]:[UIImage imageNamed:@"sfm_right_arrow.png"];
    self.expandImg.image = img;
}

- (void)setDetailLabelText
{
    self.detailLabel.text = [[TagManager sharedInstance] tagByName:kTag_Details];
}
- (void)dealloc {
    
}

@end

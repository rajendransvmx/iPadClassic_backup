//
//  SFMPageFieldCell.m
//  ServiceMaxMobile
//
//  Created by Aparna on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageFieldCollectionViewCell.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"


#define SMXLableWidth 270


@implementation SFMPageFieldCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isShowMoreButton = NO;
        _fieldName = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_fieldName];
        
        _fieldValue = [[UILabel alloc]initWithFrame:CGRectZero];
        _fieldValue.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:_fieldValue];
        
      
        
        _moreButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:_moreButton];
        _moreButton.hidden = YES;
        
        [self setFrameForSubViews];


        self.moreButton.backgroundColor = [UIColor clearColor];
        [_moreButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateNormal];
        [_moreButton setTitleColor:[UIColor colorWithHexString:kOrangeColor] forState:UIControlStateSelected];
        _moreButton.titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
        [_moreButton setTitle:[[TagManager sharedInstance]tagByName:kTagmore] forState:UIControlStateNormal];
        [_moreButton setTitle:[[TagManager sharedInstance]tagByName:kTagmore] forState:UIControlStateSelected];
        
        _fadeOutImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _fadeOutImageView.backgroundColor = [UIColor clearColor];//HS 12 Jan
        //[self.contentView addSubview:_fadeOutImageView]; //HS 12 Jan commented
        [_fieldValue addSubview:_fadeOutImageView];//HS 12 Jan added
        _fadeOutImageView.hidden = YES;
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self setFrameForSubViews];
}

- (void)setFrameForSubViews
{
    CGRect contentViewFrame = self.contentView.frame;
    
    CGRect fieldNameLabelFrame = CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, contentViewFrame.size.width, contentViewFrame.size.height/2 - 5);
    self.fieldName.frame = fieldNameLabelFrame;
    
    //CGRect fieldValueLabelFrame = CGRectMake(contentViewFrame.origin.x, CGRectGetMaxY(self.fieldName.bounds), contentViewFrame.size.width, contentViewFrame.size.height/2+5); //HS 12 Jan commented
    CGRect fieldValueLabelFrame = CGRectMake(contentViewFrame.origin.x, CGRectGetMaxY(self.fieldName.bounds), SMXLableWidth-22, contentViewFrame.size.height/2+5); //HS 12 Jan

    
    self.fieldValue.frame = fieldValueLabelFrame;
  //  self.fieldValue.lineBreakMode = NSLineBreakByClipping;//HS 12 Jan
   // self.fieldValue.backgroundColor = [UIColor clearColor];//HS 12 Jan


    
    CGFloat buttonLength = 40;
    if (self.isShowMoreButton) {
        
       // fieldValueLabelFrame = CGRectMake(contentViewFrame.origin.x, CGRectGetMaxY(self.fieldName.bounds), contentViewFrame.size.width - buttonLength - 5, contentViewFrame.size.height/2+5);//HS 12 Jan
        fieldValueLabelFrame = CGRectMake(contentViewFrame.origin.x, CGRectGetMaxY(self.fieldName.bounds), SMXLableWidth-62, contentViewFrame.size.height/2+5);//HS 12 Jan

        self.fieldValue.frame = fieldValueLabelFrame;

       // self.fieldValue.backgroundColor = [UIColor clearColor];//HS 12 Jan
        self.moreButton.hidden = NO;
        
        UIImage *fadeoutImage = [UIImage imageNamed:@"fadeout"];
        //CGRect fadeOutImageViewFrame = CGRectMake(fieldValueLabelFrame.size.width - fadeoutImage.size.width,self.fieldValue.frame.origin.y + (self.fieldValue.frame.size.height - fadeoutImage.size.height)/2,fadeoutImage.size.width,fadeoutImage.size.height); //HS 12 Jan commented
        CGRect fadeOutImageViewFrame = CGRectMake(fieldValueLabelFrame.size.width - fadeoutImage.size.width,0 ,fadeoutImage.size.width,fadeoutImage.size.height); //HS 12 Jan

        self.fadeOutImageView.frame = fadeOutImageViewFrame;
        self.fadeOutImageView.backgroundColor = [UIColor clearColor];//HS 12 Jan
        self.fadeOutImageView.image = fadeoutImage;
        self.fadeOutImageView.hidden = NO;
    } else {
        
        
        self.moreButton.hidden = YES;
        self.fadeOutImageView.hidden = YES; 
    }
    
    CGRect moreButtonFrame = CGRectMake(fieldValueLabelFrame.size.width,self.fieldValue.frame.origin.y + (self.fieldValue.frame.size.height - 10)/2,buttonLength,10);
    self.moreButton.frame = moreButtonFrame;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.moreButton.hidden = YES;
    self.isShowMoreButton = NO;
    self.fadeOutImageView.hidden = YES;

    [self setFrameForSubViews];
}

-(void)resetLayout
{
    [self setNeedsLayout];
}
@end

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

@implementation DebriefSectionView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self populateUi];
        [self addGesture];
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
    
    //self.expandImg.frame = imageViewFrame;
    
    CGRect imgFrame = self.expandImg.frame;
    
//    CGRect labelFrame = CGRectMake(self.frame.origin.x + imgFrame.size.width+ 20 , 0, width-imgFrame.size.width-20,self.frame.size.height);
//    self.sectionLabel.frame = labelFrame;
//    self.sectionLabel.center =   self.expandImg.center ;
    
    
        CGRect labelFrame = CGRectMake(0, 0, width-imgFrame.size.width-20,self.frame.size.height);
        self.sectionLabel.bounds = labelFrame;
        self.sectionLabel.center =  CGPointMake( width/2 + 30  , y) ;

    

}






-(void)addGesture
{
    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionTapped)];
    [self addGestureRecognizer:gesture];
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


- (void)dealloc {
    
}

@end

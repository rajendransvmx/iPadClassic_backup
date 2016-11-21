//
//  SFMPageReferenceFieldCollectionViewCell.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageReferenceFieldCollectionViewCell.h"
#import "StyleManager.h"

@interface  SFMPageReferenceFieldCollectionViewCell ()

@end


@implementation SFMPageReferenceFieldCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chatButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.mailButton = [[UIButton alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)layoutSubviews { // Override this method to reload the subviews frames.
    
    [super layoutSubviews];
    
    //Reload subview frames only if text exceeds the specified width and it both mail and chat buttons visible.
    if (self.isShowMoreButton && self.contactFieldSubViewType == ContactSubviewTypeBoth) {
        [self reloadSubViewsFrames];
    }
}

/*
 Description: This method will reload the frames only if contact fieldValue text exceeds the
 specified limit and if both buttones i.e mail and chat buttons visible on the page layout.
 */
- (void)reloadSubViewsFrames {
    
    CGFloat width = 0.0;
    NSInteger spaceBetweenFieldValueAndMoreButton = 10;
    NSInteger spaceBetweenMoreButtonAndMailButton = 15;
    width = self.contentView.frame.size.width - (self.contentView.frame.size.width - self.mailButton.frame.origin.x) - spaceBetweenFieldValueAndMoreButton - self.moreButton.frame.size.width - spaceBetweenMoreButtonAndMailButton; // 205
    CGRect newFrameForFieldValueLabel = CGRectMake(self.fieldValue.frame.origin.x, self.fieldValue.frame.origin.y, width, self.fieldValue.frame.size.height);
    self.fieldValue.frame = newFrameForFieldValueLabel;
    
    UIImage *fadeoutImage = [UIImage imageNamed:@"fadeout"];
    CGRect fadeOutImageViewFrame = CGRectMake(self.fieldValue.frame.size.width - fadeoutImage.size.width,0 ,fadeoutImage.size.width,fadeoutImage.size.height);
    self.fadeOutImageView.frame = fadeOutImageViewFrame;
    self.fadeOutImageView.backgroundColor = [UIColor clearColor];
    
    CGRect newFrameForMoreButton = CGRectMake(newFrameForFieldValueLabel.origin.x + newFrameForFieldValueLabel.size.width + 4, self.moreButton.frame.origin.y - 11, self.moreButton.frame.size.width, self.moreButton.frame.size.height + 20);
    self.moreButton.frame = newFrameForMoreButton;
    
}

- (void)isRefernceRecordExist:(BOOL)isRefernceRecordExist
{
    self.fieldValue.backgroundColor = [UIColor clearColor]; //HS 12Jan

    if (isRefernceRecordExist) {
        self.fieldValue.textColor = [UIColor getUIColorFromHexValue:@"#E15001"];

        [self addTapGesture];
    }
    else
    {
        self.fieldValue.textColor = [UIColor blackColor];
       // self.fieldValue.userInteractionEnabled = NO; // Disable the userInteraction if reference record not exits. Bug ID:013917

    }
}

- (void)configureCellForContext:(ContactSubviewType)context
{
    switch (context) {
        case 1:
            [self addMailButtonAsSubView];
            break;
        case 2:
            [self addChatButtonAsSubView];
            break;
        case 3:
            [self addMailAndChatBuutonAsSubView];
            break;
        default:
            break;
    }
}

- (void)addMailAndChatBuutonAsSubView
{
    [self addChatButtonAsSubView];
    [self addMailButtonAsSubView];
}

- (void)addChatButtonAsSubView
{
    [self.contentView addSubview:self.chatButton];
    [self.chatButton setImage:[UIImage imageNamed:@"Chat-new.png"] forState:UIControlStateNormal];
    CGRect frame = CGRectMake(0, 0, 30, 27);
    CGFloat rightPadding = 3;
    //align on top right
    CGFloat xPosition = CGRectGetWidth(self.contentView.frame) - (CGRectGetWidth(frame)/2) - rightPadding;
    self.chatButton.frame = frame;
    self.chatButton.center = CGPointMake(xPosition, self.contentView.center.y);
    self.chatButton.tag = 999;
    
    //autoresizing so it stays at top right (flexible left and flexible bottom margin)
    self.chatButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;//
    
    [self.chatButton addTarget:self action:@selector(chatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setFieldWidthForFrame:frame withPadding:rightPadding];
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]]) {
        self.chatButton.enabled = FALSE;
    }
    else {
        self.chatButton.enabled = TRUE;
    }

}

- (void)addMailButtonAsSubView
{
    [self.contentView addSubview:self.mailButton];
    [self.mailButton setImage:[UIImage imageNamed:@"Email-new.png"] forState:UIControlStateNormal];
    CGRect frame = CGRectMake(0, 0, 30, 20);

    CGFloat rightPadding = 44;
    //align on top right
    CGFloat xPosition = CGRectGetWidth(self.contentView.frame) - (CGRectGetWidth(frame)/2) - rightPadding;
    self.mailButton.frame = frame;
    self.mailButton.center = CGPointMake(xPosition, self.contentView.center.y);
    self.chatButton.tag = 888;
    
    //autoresizing so it stays at top right (flexible left and flexible bottom margin)
    self.mailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;//
    
    [self.mailButton addTarget:self action:@selector(mailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setFieldWidthForFrame:frame withPadding:8];
    
    if(![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mailto://"]]) {
        self.mailButton.enabled = FALSE;
    }
    else {
        self.mailButton.enabled = TRUE;
    }
}

- (void)setFieldWidthForFrame:(CGRect)frame withPadding:(NSInteger )rightPadding
{
    self.fieldValue.backgroundColor = [UIColor clearColor];//HS 12Jan

    CGRect fieldFrame = self.fieldValue.frame;
    
    //fieldFrame.size.width = (fieldFrame.size.width - frame.size.width) - 8; //HS 12 Jan commented to not cut the frame more for/if we uncomment it , it will reduce the width of the text once we go to details and then got to some other page and come back text frame will get reduced (only valid for links)
    
    self.fieldValue.frame = fieldFrame;
    
    CGRect fieldFrame1 = self.fieldName.frame;
    fieldFrame1.size.width = (fieldFrame1.size.width - frame.size.width) - 8;
    self.fieldName.frame = fieldFrame1;

}

- (void)addTapGesture
{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refernceFieldTapped)];
	tapGesture.numberOfTapsRequired = 1;
	[self.fieldValue addGestureRecognizer:tapGesture];
    [self.fieldValue setUserInteractionEnabled:YES];
    [self.contentView bringSubviewToFront:self.fieldValue];
}

- (void)refernceFieldTapped
{
    if ([self.delegate conformsToProtocol:@protocol(SFMPageReferenceFieldDedegate)]) {
        [self.delegate showSFMPageViewForRerenceField:self.index];
    }
}

- (void)mailButtonClicked:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(SFMPageReferenceFieldDedegate)]) {
        [self.delegate openContactMeaageOrMail:sender fieldName:self.fieldApiName];
    }
}

- (void)chatButtonClicked:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(SFMPageReferenceFieldDedegate)]) {
        [self.delegate openContactMeaageOrMail:sender fieldName:self.fieldApiName];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.chatButton removeFromSuperview];
    [self.mailButton removeFromSuperview];
}
@end

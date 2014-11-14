//
//  SMAlertView.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 16/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "StyleGuideConstants.h"
#import "StyleManager.h"


@class SMAlertView;

@protocol SMAlertViewDelegate <NSObject>

- (void)smAlertView:(SMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface SMAlertView: UIView
{
    float width;
    float height;
}

@property(nonatomic, strong) UILabel    *titleLabel;
@property(nonatomic, strong) UIView     *alertViewContainer;
@property(nonatomic, strong) UIButton   *cancelButton;
@property(nonatomic, strong) UIButton   *otherButton;
@property(nonatomic, strong) id<SMAlertViewDelegate> alertDelegate;

- (id)initWithTitle:(NSString*)title
           delegate:(id<SMAlertViewDelegate>)alertViewDelegate
  cancelButtonTitle:(NSString*)cancelButtonTitle
   otherButtonTitle:(NSString *)otherButtonTitle;

@end



//
//  SMXLable.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 10/17/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMXLable : UILabel
{
    UIButton *moreButton;
}
@property (nonatomic ,strong)UIButton *moreButton;
@property(nonatomic, strong) UIPopoverController * popOver;
@property(nonatomic,strong) NSString *headerText;
-(void)checkString;
@end

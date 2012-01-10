//
//  cusButton.m
//  iService
//
//  Created by Pavamanaprasad Athani on 26/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import "cusButton.h"

@implementation cusButton 
@synthesize button_info;

-(id)initWithFrame:(CGRect)frame  buttonTitle:(NSString *)title  buttonInfo:(NSDictionary *)buttonInfo;
{
    self = [super  initWithFrame:frame];
    if(self)
    {
        //self.titleLabel.text = title;
        self.button_info = buttonInfo;
        //self.titleLabel.textColor = [UIColor blackColor];
        //self.titleLabel.numberOfLines = 0;
        //self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.userInteractionEnabled = YES;
    }
    return self;
}

@end

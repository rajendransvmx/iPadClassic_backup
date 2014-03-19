//
//  cusButton.h
//  iService
//
//  Created by Pavamanaprasad Athani on 26/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cusButton : UIButton 
{
    NSDictionary * button_info;
}
@property (nonatomic , retain) NSDictionary * button_info;
-(id)initWithFrame:(CGRect)frame  buttonTitle:(NSString *)tittle  buttonInfo:(NSDictionary *)buttonInfo;
@end

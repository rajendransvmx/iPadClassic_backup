//
//  CusTextField.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "CusTextField.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"

@implementation CusTextField

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUP];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUP];
}

- (void)setUP
{
    self.borderStyle = UITextBorderStyleNone;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 3.0f;
    self.backgroundColor = [UIColor whiteColor];
}


- (void)drawPlaceholderInRect:(CGRect)rect
{
    UIColor *colour = [UIColor colorFromHexString:@"#A1A1A1"];
    
    UIFont *fontType = [UIFont fontWithName:kHelveticaNeueItalic
                                        size:kFontSize18];

    
    NSDictionary *attrsDictionaryType2 = @{NSFontAttributeName:fontType,
                                           NSForegroundColorAttributeName:colour};

    CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attrsDictionaryType2 context:nil];
    [self.placeholder drawAtPoint:CGPointMake(10, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attrsDictionaryType2];
}

@end

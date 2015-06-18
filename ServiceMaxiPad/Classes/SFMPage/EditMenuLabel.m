//
//  EditMenuLabel.m
//  ServiceMaxiPad
//
//  Created by Madhusudhan.HK on 6/15/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "EditMenuLabel.h"
#import "UIColor+SMXMoreColors.h"

@implementation EditMenuLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    return (action == @selector(copy:));
}


- (BOOL)becomeFirstResponder
{
    self.backgroundColor = [UIColor copyTextHighlightingColorForHexString:@"#ccddee"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    return [super becomeFirstResponder];
}


- (BOOL)resignFirstResponder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 1.0;
    return [super resignFirstResponder];
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.text];
}

@end

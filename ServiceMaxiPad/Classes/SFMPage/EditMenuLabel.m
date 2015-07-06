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
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self isLongPressGestureRecognizerEnabled:YES];
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

-(void)awakeFromNib {
    
    [self isLongPressGestureRecognizerEnabled:YES];
    
}
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    NSAttributedString * attributedText =
    [[NSAttributedString alloc]initWithString:self.text
                                   attributes:@{NSBackgroundColorAttributeName : [UIColor copyTextHighlightingColorForHexString:@"#ccddee"]}];
    self.opaque = NO;
    self.attributedText = attributedText;
    return [super becomeFirstResponder];
    
}


- (BOOL)resignFirstResponder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    NSAttributedString * attributedText =
    [[NSAttributedString alloc]initWithString:self.text
                                   attributes:@{NSBackgroundColorAttributeName : [UIColor clearColor]}];
    self.opaque = NO;
    self.attributedText = attributedText;
    return [super resignFirstResponder];
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:self.text];
}

#pragma mark - Custom methods..

-(void) isLongPressGestureRecognizerEnabled:(BOOL)status
{
    if (status){
      UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showEditMenuViewForLongPressGesture:)];
        [self addGestureRecognizer:gestureRecognizer];
        self.userInteractionEnabled = YES;
        
    }
}

#pragma mark - END

#pragma mark - UIGestureRecognizer

- (void)showEditMenuViewForLongPressGesture:(UIGestureRecognizer *)recognizer
{
   
    if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        CGPoint location = [recognizer locationInView:[recognizer view]];
        [recognizer.view becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:recognizer.view];
        [menuController setMenuVisible:YES animated:YES];
    }
   
    
}

#pragma mark - END

@end

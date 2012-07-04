//
//  CusLabel.m
//  CustomClassesipad
//
//  Created by Developer on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusLabel.h"

extern void SVMXLog(NSString *format, ...);
@implementation CusLabel
@synthesize id_;
@synthesize object_api_name;
@synthesize refered_to_table_name;
@synthesize controlDelegate;
#define DOUBLE_TAP_DELAY   0.35

// @synthesize shouldResizeAutomatically;

-(id)initWithFrame:(CGRect)frame ;
{
    self = [super  initWithFrame:frame];
    if(self)
    {
      //  self.adjustsFontSizeToFitWidth=TRUE;
        self.numberOfLines = 0;
        
        self.lineBreakMode = UILineBreakModeWordWrap;
        self.autoresizesSubviews = TRUE;        
    }
    
    return self;
}

-(NSString *) getLabel
{
    return self.text;
}

- (void) setShouldResizeAutomatically:(BOOL)_shouldResizeAutomatically
{
    if (!_shouldResizeAutomatically)
        return;
    
    [self sizeToFit];
    
    /*
    CGFloat maxHeight = 99999;
    
    NSString * txt = self.text;
    
    CGSize strSize = [txt sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, maxHeight)];

    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    // CGSize newSize = [txt sizeWithFont:[UIFont systemFontOfSize:14] forWidth:size.width lineBreakMode:UILineBreakModeWordWrap];

    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, strSize.height);
    */
}

- (BOOL) shouldResizeAutomatically
{
    return shouldResizeAutomatically;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    NSUInteger tapCount = [touch tapCount];
    switch (tapCount)
    {
        case 1:
            [self performSelector:@selector(tapRecognizer:) withObject:[NSNumber numberWithInt:1] afterDelay:DOUBLE_TAP_DELAY];
            break;
        case 2:
            [self performSelector:@selector(tapRecognizer:) withObject:[NSNumber numberWithInt:2] afterDelay:0];
            break;
    }
}

- (void) tapRecognizer:(NSNumber *)tapCount
{
    if ((tapCount.intValue == 1) && !isDoubleTap)
    {
        SMLog(@"Single Tap");
        [controlDelegate singleTapOncusLabel:self];
    }
    
    if (tapCount.intValue == 2)
    {
        isDoubleTap = YES;
        [self performSelector:@selector(doubleTapped) withObject:nil afterDelay:DOUBLE_TAP_DELAY];
        SMLog(@"Double Tap");
    }
}

- (void) doubleTapped
{
    isDoubleTap = NO;
    [controlDelegate doubleTapOnCusLabel:self];
    
}


@end

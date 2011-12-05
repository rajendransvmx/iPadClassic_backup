//
//  CusLabel.m
//  CustomClassesipad
//
//  Created by Developer on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusLabel.h"

@implementation CusLabel

// @synthesize shouldResizeAutomatically;

-(id)initWithFrame:(CGRect)frame
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

@end

//
//  UIBarButtonItem+TKCategory.m
//  Created by Devin Ross on 3/23/11.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "UIBarButtonItem+TKCategory.h"
#import "UIButton+TKCategory.h"
#import "TagManager.h"

@implementation UIBarButtonItem (TKCategory)


+ (UIBarButtonItem*) barButtonItemWithImage:(UIImage*)img highlightedImage:(UIImage*)highlighedImage target:(id)t selector:(SEL)s{
	
	CGRect r = CGRectZero;
	r.size = img.size;
	
	UIButton *btn = [UIButton buttonWithFrame:r image:img highlightedImage:highlighedImage];
	
	[btn addTarget:t action:s forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
	item.target = t;
	item.action = s;
	return item;
	
}

+ (UIBarButtonItem *) customNavigationBackButtonWithTitle:(NSString *)title forTarget:(id)target forSelector:(SEL)selector{
    
    UIImageView *backArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OPDocBackArrow.png"]];
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 150, backArrow.frame.size.height)];
    backLabel.text = [[TagManager sharedInstance]tagByName:title];
    backLabel.font = [UIFont systemFontOfSize:17];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textAlignment = NSTextAlignmentLeft;
    backLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (backArrow.frame.size.width + backLabel.frame.size.width), backArrow.frame.size.height)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:backArrow];
    [backView addSubview:backLabel];
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [backView addGestureRecognizer:tap];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    return barButtonItem;
    
}

@end

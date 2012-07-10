//
//  CTextField.m
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation CTextField

@synthesize controlDelegate;
@synthesize delegateHandler;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize isinViewMode;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame lableValue:(NSString *)lableValue controlType:(NSString *)controlType isinViewMode:(BOOL)mode
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        delegateHandler = [[CTextFieldHandlerNum alloc] init];
        delegateHandler.delegate = self;
        delegateHandler.rect = frame;
        delegateHandler.lableValue = lableValue;
        delegateHandler.control_type = controlType;
        self.delegate = delegateHandler;
        self.isinViewMode = mode;
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.keyboardType = UIKeyboardTypeNumberPad;

        /*if([controlType isEqualToString:@"phone"])
        {
           
            
            UIImage * image = [UIImage imageNamed:@"phone.png"];
            UIControl * c = [[UIControl alloc] initWithFrame:(CGRect){CGPointZero, image.size}];
            c.layer.contents = (id)image.CGImage;
            [c addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
            self.rightView = c;
            self.rightViewMode = UITextFieldViewModeAlways;
        }*/
    }
    return self;
}

- (void) setRequired:(BOOL)_required
{
    required = _required;
    if (required)
    {
        UIImageView * leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"required.png"]];
        self.leftView = leftImageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [leftImageView release];
    }
}

-(void) dealloc
{
    [super dealloc];
}

- (void) setReadOnly:(BOOL)flag
{
    self.enabled = !flag;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - CTextFieldHandlerNum Delegate Method
- (void) didChangeText:(NSString *)_text
{
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:_text fieldKeyValue:_text controlType:self.control_type];
}
-(void)imageTapped:(id)sender
{
    if(!isinViewMode)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.text]];
    }
}

@end

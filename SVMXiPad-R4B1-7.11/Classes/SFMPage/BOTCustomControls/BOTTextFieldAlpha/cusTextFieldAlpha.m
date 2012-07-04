//
//  cusTextFieldAlpha.m
//  CustomClassesipad
//
//  Created by Developer on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cusTextFieldAlpha.h"


@implementation cusTextFieldAlpha

@synthesize controlDelegate;
@synthesize delegatehandler;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame control_type:(NSString *)_control_type isInViewMode:(BOOL)mode
{
    self = [super initWithFrame:frame];
    if (self)
    {
        delegatehandler = [[AlhaTextHandler alloc] init];
        delegatehandler.popOverView = self;
        delegatehandler.rect = frame;
        delegatehandler.delegate = self;
        delegatehandler.control_type = _control_type;
        delegatehandler.isInViewMode = mode;
        self.delegate  = delegatehandler;
        
        // Custom initialization
       
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if ([_control_type isEqualToString:@"email"])
        {
            self.keyboardType = UIKeyboardTypeEmailAddress;
        }
        /*if ([_control_type isEqualToString:@"email"])
        {
            UIImageView * rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email_icon.png"]];
            self.rightView = rightImageView;
            self.rightViewMode = UITextFieldViewModeAlways;
            [rightImageView release];   
        }*/
        
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selector:) name:UITextFieldTextDidChangeNotification object:self];
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

- (void) selector:(NSNotification *) notification
{
    // cusTextFieldAlpha * field = [notification object];
    // SMLog(@"%@", field.text);
}

-(void) dealloc
{
    [super dealloc];
}

#pragma mark - AlhaTextHandlerDelegate Method

-(void) didChangeText:(NSString *)text
{
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:text fieldKeyValue:text controlType:self.control_type];
}


@end

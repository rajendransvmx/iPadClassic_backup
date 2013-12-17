//
//  TimePIckerTextField.m
//  CustomClassesipad
//
//  Created by Developer on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimePIckerTextField.h"

@implementation TimePIckerTextField

@synthesize controlDelegate;
@synthesize delegateHandler;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame inView:(UIView *)inView
{
    frame.size.height=31;     
    self = [super initWithFrame:frame];
    if (self)
    {
        delegateHandler = [[TPTextFieldHandler alloc] init];
        delegateHandler.pickerFrame = frame;
        delegateHandler.superView =self;
        delegateHandler.delegate = self;
        
        self.delegate = delegateHandler;
        self.textAlignment=UITextAlignmentCenter;
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews=TRUE;
        self.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        
        NSDate *date=[[[NSDate alloc] init] autorelease];
        NSDateFormatter *frm=[[[NSDateFormatter alloc] init] autorelease];
        [frm setDateFormat:@"hh:mm:ss a"];
        self.text=[frm stringFromDate:date];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:delegateHandler action:@selector(tapTimePicker:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    return self;
}

- (void) setRequired:(BOOL)_required
{
    required = _required;
    if (required)
    {
        UIImageView * leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"required.png"]];
		
		//Shrinivas : Linked SFM UI Automation
		leftImageView.isAccessibilityElement = TRUE;
		[leftImageView setAccessibilityIdentifier:@"required"];
		
        self.leftView = leftImageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [leftImageView release];
    }
}

-(void)setTextBoxToPickerValue:(NSString *)string
{
    self.text = string;
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
  
}
-(void)setTimePickertoTextFielddate
{
    NSDateFormatter *frm=[[[NSDateFormatter alloc] init] autorelease];
    [frm  setDateFormat:@"hh:mm:ss a"];
    NSDate * date = [frm dateFromString:self.text];
    delegateHandler.timePicker.picker.date = date;
 
}

-(void)dealloc
{
    [super dealloc];
}

@end

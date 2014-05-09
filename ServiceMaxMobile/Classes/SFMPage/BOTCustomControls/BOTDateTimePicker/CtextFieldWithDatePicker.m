//
//  CtextFieldWithDatePicker.m
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CtextFieldWithDatePicker.h"

/*Accessibility Changes*/
#import "AccessibilityGlobalConstants.h"

@implementation CtextFieldWithDatePicker

@synthesize delegateHandler;
@synthesize flag;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize controlDelegate;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame 
{
    //frame.size.height = TEXTFIELD_HEIGHT;
    self = [super initWithFrame:frame];

    if (self)
    {
        delegateHandler = [[TextFieldHandler alloc] init];
        delegateHandler.pickerFrame = frame;
        
        [self setClipsToBounds:NO];
            
        delegateHandler.super_view = self;
        delegateHandler.delegate = self;

       
        self.delegate = delegateHandler;
        self.textAlignment = UITextAlignmentLeft;

        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:delegateHandler action:@selector(tapDateTimePicker:)];
        [self addGestureRecognizer:tapMe];
        [tapMe release];

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
//		[leftImageView setAccessibilityIdentifier:@"required"];
        /*Accessibility changes*/
        [leftImageView setAccessibilityIdentifier:kAccRequiredField];

		
        self.leftView = leftImageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [leftImageView release];
    }
}

-(void)setTextBoxToPickerValue:(NSString *)string
{
    self.text=string;
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
             
}
//sahana Aug 10th
-(void)deleteTextFieldValue
{
    self.text = @"";
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
}
-(void)setDatePickerDatetoTextFielddate
{
    NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
    NSDate * _date;

    [frm  setDateFormat:DATETIMEFORMAT];
    _date = [frm dateFromString:self.text];
    if(self.text!=nil && _date!=nil)
    {       
        delegateHandler.datepicker.picker.date = _date;
    }
    else
    {
        //sahana 20th Aug 2011
        delegateHandler.datepicker.picker.date = [NSDate date];
    }
}

-(NSDate *)getDate
{
    NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
    [frm  setDateFormat:DATETIMEFORMAT];
    NSDate * _date  = [frm dateFromString:self.text];
    return _date;
    
}

-(void) setDate:(NSDate *)date
{
    NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
   [frm  setDateFormat:DATETIMEFORMAT];
    self.text = [frm stringFromDate:date];
}

-(void)dealloc
{
    [delegateHandler release];
    [super dealloc];
}

@end

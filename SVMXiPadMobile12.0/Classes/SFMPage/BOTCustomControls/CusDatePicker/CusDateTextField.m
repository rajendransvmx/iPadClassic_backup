//
//  CusDateTextField.m
//  CustomClassesipad
//
//  Created by Developer on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusDateTextField.h"

@implementation CusDateTextField

@synthesize flag;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize controlDelegate;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame 
{
    //frame.size.height=31;     
    self = [super initWithFrame:frame];
    if (self)
    {
        delegateHandler = [[CusDateTextFieldHandler alloc] init];
        delegateHandler.pickerFrame = frame;
        delegateHandler.superView =self;
        delegateHandler.delegate = self;
        
        self.delegate = delegateHandler;
        self.textAlignment=UITextAlignmentLeft;
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews=TRUE;
        self.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:delegateHandler action:@selector(tapDatePicker:)];
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
        self.leftView = leftImageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [leftImageView release];
    }
}

-(void)dealloc
{
    [super dealloc];
}

-(void) setDateTextField:(NSString *)date 
{
    self.text = date;
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
}

-(void) setPODatepickerValue
{
    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
    NSDate * _date ;

    [frm  setDateFormat:@"MMM dd yyyy"];
    _date = [frm dateFromString:self.text];  
    if(self.text != nil && _date!= nil )
    {
        delegateHandler.contentView.datePicker.date = _date;
    } 
    else
    {
        //sahana 20th Aug 2011
        delegateHandler.contentView.datePicker.date = [NSDate date];
    }
    
}

-(void) deleteDateTextField
{
    self.text = @"";
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
}

@end

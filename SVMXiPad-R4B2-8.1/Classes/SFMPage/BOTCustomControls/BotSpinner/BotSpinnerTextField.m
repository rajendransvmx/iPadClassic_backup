//
//  BotSpinnerTextField.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BotSpinnerTextField.h"


@implementation BotSpinnerTextField

@synthesize TFHandler; 
@synthesize spinnerData;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize controlDelegate;
@synthesize control_type;

-(id)initWithFrame:(CGRect)frame initArray:(NSArray *)arr
{
    self=[super initWithFrame:frame];
    if(self)
    { 
        TFHandler = [[SpinnerTFhandler alloc] init];
        TFHandler.TextfieldView = self;
        TFHandler.rect = frame;
        TFHandler.delegate = self;
        TFHandler.spinnerData = arr;
        TFHandler.spinnerValue_index = [arr count]/2;
        TFHandler.flag = TRUE;
        self.delegate = TFHandler;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.spinnerData = arr;
    }
    
    return  self;
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
-(void) setTextField :(NSString *)str
{
    self.text=str;
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
}
-(void)setSpinnerValue
{
    if(TFHandler.flag==TRUE)
    {
      TFHandler.contentView.index = TFHandler.spinnerValue_index;
       // return;
    }
    else
    {
      NSInteger index;
      index=[spinnerData indexOfObject:self.text];
   // [TFHandler.contentView.valuePicker selectRow:TFHandler.spinnerValue_index inComponent:1 animated:YES];

        TFHandler.contentView.index=index;
    }
}


@end

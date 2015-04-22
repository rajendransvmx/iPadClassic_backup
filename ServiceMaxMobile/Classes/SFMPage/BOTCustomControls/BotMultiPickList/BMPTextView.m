//
//  BMPTextView.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BMPTextView.h"
#import "AppDelegate.h"

/*Accessibility Changes*/
#import "AccessibilityGlobalConstants.h"
@implementation BMPTextView

@synthesize controlDelegate;

@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;

//5878:Aparna
@synthesize TextFieldDelegate;

-(id) initWithFrame:(CGRect)frame  initArray:(NSArray *)arr
{
    self=[super initWithFrame:frame];
    if(self)
    {
        TextFieldDelegate = [[MPTextFHandler alloc] init];
        self.delegate=TextFieldDelegate;
        TextFieldDelegate.pickerContent=arr;
        TextFieldDelegate.view=self;
        TextFieldDelegate.pickerrect=frame;
        TextFieldDelegate.delegate=self;
        self.autoresizesSubviews=TRUE;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        self.borderStyle=UITextBorderStyleRoundedRect;
        TextFieldDelegate.str=@"";
        TextFieldDelegate.flag=TRUE;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:TextFieldDelegate action:@selector(tapMultiPicklist:)];
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
//		[leftImageView setAccessibilityIdentifier:@"required"];
        /*Accessibility changes*/
        [leftImageView setAccessibilityIdentifier:kAccRequiredField];
		
        self.leftView = leftImageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [leftImageView release];
    }
}

-(void)setTextfield:( NSMutableArray *) values
{
    TextFieldDelegate.pickListValues=values;
    
    NSString * textFieldValue=[[[NSString alloc] init] autorelease];
    NSMutableDictionary *dict;
    
    NSString *value = nil;
    int i;
    @try{
    for(i = 0; i < [values count]; i++)
    {
        dict=[values objectAtIndex:i];
        //5878:Aparna
        value = [dict valueForKey:[[dict allKeys] objectAtIndex:0]];
        //Radha 9th Aug 2011
        if([value intValue] == 1)
        {
            if ([textFieldValue length] > 0)
                textFieldValue = [textFieldValue stringByAppendingString:[NSString stringWithFormat:@";%@", [[dict allKeys] objectAtIndex:0]]];
            else
                textFieldValue = [textFieldValue stringByAppendingString:[[dict allKeys] objectAtIndex:0]];
        }
    }

    self.text=textFieldValue;
    
    //apend the keys Corresponding to the pick list
    NSMutableArray * keyVal	 = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * keyValueString =[[[NSString alloc] init] autorelease];
     AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
    {
        ZKDescribeSObject * sObj = [appDelegate.describeObjectsArray objectAtIndex:i];
        ZKDescribeField * desField = [sObj fieldWithName:fieldAPIName];
        if (desField == nil)
            continue;
        else
        {
            NSArray * multipicklistArray = [desField picklistValues];
            NSArray * array = [textFieldValue componentsSeparatedByString:@";"];
            for (int j = 0; j < [array count]; j++)
            {
                for (int i = 0; i < [multipicklistArray count]; i++)
                {
                    NSString * value = [[multipicklistArray objectAtIndex:i] label];
                    if ([value isEqualToString:[array objectAtIndex:j]])
                    {
                        [keyVal addObject:[[multipicklistArray objectAtIndex:i] value]];
                        break;
                    }
                }
            }
        }
    }
    for(int j = 0 ; j < [keyVal count]; j++)
    {
        if ([keyValueString length] > 0)
            keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
        else
            keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
    }

    [keyVal release];
    
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:textFieldValue fieldKeyValue:keyValueString controlType:control_type];
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name BMPTextView :setTextfield %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason BMPTextView :setTextfield %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

-(void)dealloc
{
    [TextFieldDelegate release];
    [super dealloc];
    
}

@end

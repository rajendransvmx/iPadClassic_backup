//
//  BMPTextView.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BMPTextView.h"
#import "iServiceAppDelegate.h"
@implementation BMPTextView

@synthesize controlDelegate;

@synthesize str;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;

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
        self.str=@"";
        TextFieldDelegate.str=str;
        TextFieldDelegate.flag=TRUE;
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

-(void)setTextfield:( NSMutableArray *) values
{
    TextFieldDelegate.pickListValues=values;
    
    if (str != nil)
    {
        [str release];
        str = nil;
    }
    str = [[NSString alloc] init]; 
    NSInteger len;
    NSString * textFieldValue=[[[NSString alloc] init] autorelease];
    NSMutableDictionary *dict;
    int i;
    for(i = 0; i < [values count]; i++)
    {
        dict=[values objectAtIndex:i]; 
        str = [dict valueForKey:[TextFieldDelegate.pickerContent objectAtIndex:i]];
        //Radha 9th Aug 2011
        if([str isEqualToString:@"1"])
        {
            if ([textFieldValue length] > 0)
                textFieldValue = [textFieldValue stringByAppendingString:[NSString stringWithFormat:@";%@", [TextFieldDelegate.pickerContent objectAtIndex:i]]];
            else
                textFieldValue = [textFieldValue stringByAppendingString:[TextFieldDelegate.pickerContent objectAtIndex:i]];
        }
    }

    self.text=textFieldValue;
    
    //apend the keys Corresponding to the pick list
    NSMutableArray * keyVal	 = [[NSMutableArray alloc] initWithCapacity:0];
    NSString * keyValueString =[[[NSString alloc] init] autorelease];
     iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
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
}

-(void)dealloc
{
    [TextFieldDelegate release];
    [str release];
    [super dealloc];
    
}

@end

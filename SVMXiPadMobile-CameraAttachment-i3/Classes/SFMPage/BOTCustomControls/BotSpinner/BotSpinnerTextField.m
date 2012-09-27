//
//  BotSpinnerTextField.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BotSpinnerTextField.h"
#import "BitSet.h"

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
    //for dependent picklist 
    [self.controlDelegate clearTheDependentPicklistValue:self.fieldAPIName atIndexPath:indexPath controlType:control_type fieldValue:self.text];
    [self.controlDelegate didUpdateLookUp:@"" fieldApiName:@"" valueKey:@""];
    
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

-(NSArray *)getValuesForDependentPickList
{
    NSLog(@"%@" ,TFHandler.controllerName);
   NSUInteger count = [self.controlDelegate getControlFieldPickListIndexForControlledPicklist:TFHandler.controllerName atIndexPath:indexPath controlType:control_type];
    NSLog(@"%d", count);
   if(count == 9999999)
   {
       return spinnerData;
   }
    //get the count and 
    NSMutableArray * spinner_Array = [[NSMutableArray alloc] initWithCapacity:0];
    [spinner_Array addObject:@""];
   
    for(int j = 0 ; j< [TFHandler.spinnerData count];j++)
    {
        NSLog(@"--");
        NSString * obj = [TFHandler.validFor objectAtIndex:j];
        NSLog(@"object :%@", obj);
        obj = [obj stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(obj == nil || [obj isEqualToString:@""])
        {
           // NSLog(@" object  %@" , obj);
            continue;
        }
        NSLog(@" valid For %@" , TFHandler.validFor);
        NSLog(@"spinner data %@ " , TFHandler.spinnerData);
        
        BitSet *bitObj = [[BitSet alloc] initWithData:obj];
        for (int k = 0; k < [bitObj size]; k++)
        {
            if ([bitObj testBit:k]) 
            {
                // if bit k is set, this entry is valid for the
                // for the controlling entry at index k
                if(count == k)
                {
                    NSLog(@"Index of %@ = %d",obj,k);
                    
                    //add to cityData
                    [spinner_Array addObject:[TFHandler.spinnerData objectAtIndex:j]];
                    NSLog(@"SpinnerData %@", [TFHandler.spinnerData objectAtIndex:j]);
                    break;
                }
            }
        }
        
        [bitObj release];
    }
    
    return spinner_Array;
    
    /*if([spinner_Array count] == 1)
        return spinnerData;//spinner_Array;
    else
        return spinner_Array;*/
}


@end

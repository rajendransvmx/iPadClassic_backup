//
//  BotSpinnerTextField.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BotSpinnerTextField.h"
#import "BitSet.h"
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);
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
    NSString *old_Value = self.text;
    self.text=str;
    NSString * key = @"";
    if([fieldAPIName isEqualToString:@"RecordTypeId"] && [control_type isEqualToString:@"reference"])
    {
        key = [self getKeyForvalue_recordTypeId:str];
        if(key == nil)
        {
            key = @"";
        }
    }
    else
    {
        key = str;
    }
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:key controlType:self.control_type];
    //for recordtype id
    if([self.fieldAPIName isEqualToString:@"RecordTypeId"])
    {
        if(![old_Value isEqualToString:str])
        {
            SMLog(@"Update PickList Values ");
            SMLog(@"Old Value = %@ and New Value = %@",old_Value,str);
            if(old_Value != nil)
            /*[self.controlDelegate clearTheDependentRecordTypePicklistValue:old_Value 
                                                               atIndexPath:indexPath 
                                                            controlType:control_type]; */     
            [self.controlDelegate clearTheDependentRecordTypePicklistValue:str 
                                                               atIndexPath:indexPath 
                                                               controlType:control_type];      

        }
    }
    else
    {
        //for dependent picklist 
        [self.controlDelegate clearTheDependentPicklistValue:self.fieldAPIName atIndexPath:indexPath controlType:control_type];

    }

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
    SMLog(@"%@" ,TFHandler.controllerName);
   NSUInteger count = [self.controlDelegate getControlFieldPickListIndexForControlledPicklist:TFHandler.controllerName atIndexPath:indexPath controlType:control_type];
    SMLog(@"%d", count);
   if(count == 9999999)
   {
       return spinnerData;
   }
    //get the count and 
    NSMutableArray * spinner_Array = [[NSMutableArray alloc] initWithCapacity:0];
    [spinner_Array addObject:@""];
   
    for(int j = 0 ; j< [TFHandler.spinnerData count];j++)
    {
       // SMLog(@"--");
        NSString * obj = [TFHandler.validFor objectAtIndex:j];
        //SMLog(@"object :%@", obj);
        obj = [obj stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(obj == nil || [obj isEqualToString:@""])
        {
           // SMLog(@" object  %@" , obj);
            continue;
        }
        //SMLog(@" valid For %@" , TFHandler.validFor);
        //SMLog(@"spinner data %@ " , TFHandler.spinnerData);
        
        BitSet *bitObj = [[BitSet alloc] initWithData:obj];
        for (int k = 0; k < [bitObj size]; k++)
        {
            if ([bitObj testBit:k]) 
            {
                // if bit k is set, this entry is valid for the
                // for the controlling entry at index k
                if(count == k)
                {
                   // SMLog(@"Index of %@ = %d",obj,k);
                    
                    //add to cityData
                    [spinner_Array addObject:[TFHandler.spinnerData objectAtIndex:j]];
                   // SMLog(@"SpinnerData %@", [TFHandler.spinnerData objectAtIndex:j]);
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

-(void)clearTheDependentPickListValue
{
     [self.controlDelegate clearTheDependentPicklistValue:self.fieldAPIName atIndexPath:indexPath controlType:control_type];
}
-(NSString *)getKeyForvalue_recordTypeId:(NSString *)text_value
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary * hdr_object = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * hdr_object_name = [hdr_object objectForKey:gHEADER_OBJECT_NAME];    
    NSArray * array = [self.TFHandler.lookupData objectForKey:@"DATA"];
    NSString * name = @"", * Id_= @"";
    for (int i = 0; i < [array count]; i++)
    {
        NSArray * data = [array objectAtIndex:i];
        for (int j = 0; j < [data count]; j++)
        {
            NSDictionary * _dict = [data objectAtIndex:j];
            NSString * sobjectName = [_dict objectForKey:@"key"];
            if([sobjectName isEqualToString:@"SobjectType"])
            {
                NSString * object_name = [_dict objectForKey:@"value"];
                if([object_name isEqualToString:hdr_object_name])
                {
                    
                    for (int k = 0; k<[data count]; k++) 
                    {
                        NSDictionary * _dict1 = [data objectAtIndex:k];
                        NSString * keyValue = [_dict1 objectForKey:@"key"];
                        if ([keyValue isEqualToString:@"Name"])
                        {
                            name = [_dict1 objectForKey:@"value"];
                        }
                        if([keyValue isEqualToString:@"Id"])
                        {
                            Id_ = [_dict1 objectForKey:@"value"];
                        }
                        
                    }
                    if([name isEqualToString:text_value])
                    {
                        return  Id_;
                    }
                    break;
                }
            }
        }
    }
    
    return Id_;

}
@end

//
//  SpinnerTFhandler.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpinnerTFhandler.h"
#import "BotSpinnerTextField.h"
#import "AppDelegate.h"
void SMXLog(const char *methodContext,NSString *message);

@implementation SpinnerTFhandler
@synthesize contentView;
@synthesize POC;
@synthesize rect;
@synthesize TextfieldView;
@synthesize delegate;
@synthesize spinnerData;
@synthesize setSpinnerValuedelegate;
@synthesize spinnerValue_index;
@synthesize flag;
@synthesize validFor;
@synthesize controllerName;
@synthesize isdependentPicklist;


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

-(void)tapSpinner:(id)sender
{
	@try{
        BotSpinnerTextField * parent = (BotSpinnerTextField *)delegate;
        [parent.controlDelegate controlIndexPath:parent.indexPath];
        
        setSpinnerValuedelegate = delegate;
        
        NSMutableDictionary * return_dict = [[parent.controlDelegate getRecordTypeIdAndObjectNameForCellAtIndexPath:parent.indexPath] retain];
        NSString * SFM_ObjectName = @"" , * RecordTypeId = @"" ;
        BOOL ISRTDEPPicklist = FALSE;
        
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        if([return_dict count] >0)
        {
            RecordTypeId = [return_dict objectForKey:RecordType_Id];
            SFM_ObjectName = [return_dict objectForKey:SFM_Object];
            ISRTDEPPicklist = [appDelegate.databaseInterface  checkForRTPicklistForFieldApiName:parent.fieldAPIName objectApiname:SFM_ObjectName recordTypeId:RecordTypeId];
        }
        
        contentView = [[popOverContent alloc] init];
        if(isdependentPicklist && [controllerName length] != 0 && [validFor count] != 0)
        {
            contentView.spinnerData  = [setSpinnerValuedelegate  getValuesForDependentPickList];
        }
        else if (ISRTDEPPicklist && ![parent.fieldAPIName isEqualToString:@"RecordTypeId"])
        {
            contentView.spinnerData = [[ appDelegate.databaseInterface  getRTPicklistValuesForFieldApiName:parent.fieldAPIName objectApiName:SFM_ObjectName recordTypeId:RecordTypeId] retain];
        }
        else
        {
            contentView.spinnerData = spinnerData;
        }
        int Max_length=25;
        
        for(int i=0;i<[spinnerData count] ;i++)
        {
            NSString  * picklist_value =[spinnerData objectAtIndex:i];
            int Maxlength=[picklist_value length];
            if(Maxlength >25)
            {
                if(Maxlength >=40)
                {
                    Max_length=40;
                    break;
                }
                else
                {
                    Max_length=Maxlength;
                }
            }
            CGSize size;
            if (Max_length>25)
            {
                size=[picklist_value sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(((Max_length*13)-30),21)];
            }
            else
            {
                size=[picklist_value sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(contentView.view.frame.size.width,21)];
                
            }
            int max=size.width;
            if(max ==0 && Max_length>25)
            {
                Max_length=45;
            }
            SMLog(@"Size ====== %d",max);
            SMLog(@"Picklist Max Size %d",Max_length);
        }
        contentView.spinnerDelegate = delegate;
        setSpinnerValuedelegate = delegate;
        [setSpinnerValuedelegate setSpinnerValue];
        
        POC = [[UIPopoverController alloc] initWithContentViewController:contentView];
        if (Max_length>25)
        {
            [POC setPopoverContentSize:CGSizeMake(((Max_length*13)-30), contentView.view.frame.size.height) animated:YES];
        }
        else
        {
            [POC setPopoverContentSize:contentView.view.frame.size animated:YES];
        }
        POC.delegate = contentView;
        [POC presentPopoverFromRect:CGRectMake(0, 0, rect.size.width, rect.size.height) inView:TextfieldView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        //Shrinivas RTPicklist - Defect #3668
        NSInteger indexOfText = 0;
        NSString * defaultValue = @"";
        
        //10/04/2012 --> Changes made please integrate
        if(isdependentPicklist && [controllerName length] != 0 && [validFor count] != 0)
        {
            if (ISRTDEPPicklist)
            {
                SMLog(@"Oh God Even this is Possible");
                if ([parent.text isEqualToString:@""])
                {
                    defaultValue = [appDelegate.databaseInterface getDefaultValueForRTPicklistDependency:SFM_ObjectName recordtypeId:RecordTypeId field_api_name:parent.fieldAPIName];
                    
                    //                indexOfText = [contentView.spinnerData indexOfObject:defaultValue];
                    
                    if ([defaultValue isEqualToString:@""])
                    {
                        indexOfText = 0;
                    }
                    else
                    {
                        indexOfText = [contentView.spinnerData indexOfObject:defaultValue];
                    }
                }
                else
                {
                    indexOfText = [contentView.spinnerData indexOfObject:parent.text];
                }
            }
            else
            {
                if ([parent.text isEqualToString:@""])
                {
                    indexOfText = 0;
                }
                else
                {
                    indexOfText = [contentView.spinnerData indexOfObject:parent.text];
                }
            }
        }else if(ISRTDEPPicklist && ![parent.fieldAPIName isEqualToString:@"RecordTypeId"]){
            
            defaultValue = [appDelegate.databaseInterface getDefaultValueForRTPicklistDependency:SFM_ObjectName recordtypeId:RecordTypeId field_api_name:parent.fieldAPIName];
            SMLog(@"%@ %@", contentView.spinnerData, spinnerData);
            if ([parent.text isEqualToString:@""])
                indexOfText = [contentView.spinnerData indexOfObject:defaultValue];
            else
                indexOfText = [contentView.spinnerData indexOfObject:parent.text];
            
        }else{
            
            SMLog(@"%@ %@", contentView.spinnerData, spinnerData);
            if([contentView.spinnerData containsObject:parent.text])
            {
                indexOfText = [contentView.spinnerData indexOfObject:parent.text];
            }
        }
        
        [contentView.valuePicker selectRow:indexOfText inComponent:0 animated:YES];
	}@catch (NSException *exp) {
        SMLog(@"Exception Name SpinnerTFhandler :textFieldShouldBeginEditing %@",exp.name);
        SMLog(@"Exception Reason SpinnerTFhandler :cetextFieldShouldBeginEditingllForRowAtIndexPath %@",exp.reason);
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}


@end

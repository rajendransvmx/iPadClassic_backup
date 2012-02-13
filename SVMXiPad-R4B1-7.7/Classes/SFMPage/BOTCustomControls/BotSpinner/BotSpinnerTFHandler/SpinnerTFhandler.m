//
//  SpinnerTFhandler.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpinnerTFhandler.h"
#import "BotSpinnerTextField.h"
#import "iServiceAppDelegate.h"

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
@synthesize refSearch_id;
@synthesize refObjectName;
@synthesize lookupData;


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BotSpinnerTextField * parent = (BotSpinnerTextField *)delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    
    setSpinnerValuedelegate = delegate;
    
    contentView = [[popOverContent alloc] init];
    
       
    if(isdependentPicklist && [controllerName length] != 0 && [validFor count] != 0)
    {
       contentView.spinnerData  = [setSpinnerValuedelegate  getValuesForDependentPickList];
    }
    else
    if(([parent.controlDelegate getRecordTypeIDValue] != nil) && ![ parent.fieldAPIName isEqualToString:@"RecordTypeId"])
    {
        contentView.spinnerData  = (NSArray *)[parent.controlDelegate  getValuesForRecordTypePickList:parent.fieldAPIName];
    }
    else if([ parent.fieldAPIName isEqualToString:@"RecordTypeId"] && [parent.control_type isEqualToString:@"reference"])
    {
        //call webservice method 
        
        contentView.spinnerData = [self getLookUpForRecordTypeId];
    }
    else
    {
        //[setSpinnerValuedelegate clearTheDependentPickListValue];
        contentView.spinnerData = spinnerData;
    }
       
    POC = [[UIPopoverController alloc] initWithContentViewController:contentView];
    [POC setPopoverContentSize:contentView.view.frame.size animated:YES];
    POC.delegate = contentView;

    contentView.spinnerDelegate = delegate;
    //setSpinnerValuedelegate = delegate;
     
    [setSpinnerValuedelegate setSpinnerValue];
    [POC presentPopoverFromRect:CGRectMake(0, 0, rect.size.width, rect.size.height) inView:TextfieldView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   
   // NSInteger indexOfText = [spinnerData indexOfObject:textField.text];
     NSInteger indexOfText = [contentView.spinnerData indexOfObject:textField.text];
    [contentView.valuePicker selectRow:indexOfText inComponent:0 animated:YES];
    //sahana  recordsTypeId
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];;
    appDelegate.recordtypeId_webservice_called = FALSE;

    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
-(NSMutableArray *)getLookUpForRecordTypeId
{
    
    BotSpinnerTextField * parent = (BotSpinnerTextField *)delegate;
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];;
    appDelegate.recordtypeId_webservice_called = TRUE;
    appDelegate.wsInterface.didGetRecordTypeId = FALSE;
    
    UIActivityIndicatorView * activity_indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
//    activity_indicator.color = [UIColor blueColor];

    activity_indicator.center = CGPointMake(parent.frame.size.width/2,14);
    [parent addSubview:activity_indicator];
    activity_indicator.hidden = FALSE;
   // activity_indicator.backgroundColor = [UIColor blueColor];
    [activity_indicator setBackgroundColor:[UIColor clearColor]];
    [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];

    
    [activity_indicator startAnimating];
    if([refSearch_id isEqualToString:@""])
    {
        // Pass a 0 here for overrideRelatedLookup field
        [appDelegate.wsInterface getLookUpFieldsWithKeyword:@"" forObject:refObjectName returnTo:self setting:FALSE overrideRelatedLookup:0 lookupContext:nil lookupQuery:nil];
    }
    else
    {
        [appDelegate.wsInterface getLookUpFieldsWithKeyword:@"" forObject:refSearch_id returnTo:self setting:TRUE overrideRelatedLookup:0 lookupContext:nil lookupQuery:nil];
    }
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, FALSE)) 
    {
        NSLog(@"SFMEditCellForTable in while loop");
        if (!appDelegate.isInternetConnectionAvailable)
        {
            // [activity stopAnimating];
            appDelegate.wsInterface.sfm_response = FALSE;
            [appDelegate displayNoInternetAvailable];
            break;
        }
        if (appDelegate.wsInterface.didGetRecordTypeId)
            break;
    }
    [activity_indicator stopAnimating];
    NSDictionary * hdr_object = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * hdr_object_name = [hdr_object objectForKey:gHEADER_OBJECT_NAME];    
    NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:0];
    [arr insertObject:@"" atIndex:0];
    NSArray * array = [lookupData objectForKey:@"DATA"];
    NSString * name = @"";
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
                           // [arr insertObject:name atIndex:k++];
                             [arr insertObject:name atIndex:k+1];
                            break;
                        }
                    
                    }
                    break;
                }
            }
        }
    }
    NSLog(@"%@", arr);
    return arr;
}


- (void) setLookupData:(NSDictionary *)lookupDictionary
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];;
    appDelegate.didUserInteract = YES;
    if (!appDelegate.isInternetConnectionAvailable)
    {
        //[activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    NSDictionary * _lookupDetails = [lookupDictionary objectForKey:gLOOKUP_DETAILS];
    lookupData = _lookupDetails;
    [lookupData retain];
    appDelegate.wsInterface.didGetRecordTypeId = TRUE;
    NSLog(@"%@", lookupData);
}

@end

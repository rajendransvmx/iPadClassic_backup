//
//  MPTextFHandler.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPTextFHandler.h"
#import "BMPTextView.h"
#import "WSIntfGlobals.h"
#import "AppDelegate.h"
#import "BitSet.h"

@implementation MPTextFHandler
@synthesize     pickerContent;
@synthesize     contentView;
@synthesize     poc;
@synthesize     view;
@synthesize     pickerrect;
@synthesize     delegate;
@synthesize     str;
@synthesize     pickListValues;
@synthesize     flag;


//5878: Aparna
@synthesize isdependentPicklist;
@synthesize controllerName;
@synthesize validFor;

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
    
}

-(void) tapMultiPicklist:(id)sender
{
    BMPTextView * parent = (BMPTextView *)delegate;
    //[parent.controlDelegate controlIndexPath:parent.indexPath];
    
    contentView = [[MPickContent alloc] init];
    //sahana 9th Aug
    contentView.initialString = parent.text;;
    contentView.pickListContent=pickerContent;
    int Max_Length=25;
    
    
    //5878:Aparna
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    NSMutableDictionary * return_dict = [parent.controlDelegate getRecordTypeIdAndObjectNameForCellAtIndexPath:parent.indexPath];
    NSString * sfmObjectName = @"" , * recordTypeId = @"" ;
    BOOL isRTDependentPicklist = FALSE;
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];


    if([return_dict count] >0)
    {
        recordTypeId = [return_dict objectForKey:RecordType_Id];
        sfmObjectName = [return_dict objectForKey:SFM_Object];
        isRTDependentPicklist = [appDelegate.databaseInterface  checkForRTPicklistForFieldApiName:parent.fieldAPIName objectApiname:sfmObjectName recordTypeId:recordTypeId];
    }
    
    if(isdependentPicklist && [controllerName length] != 0 && [validFor count] != 0)
    {
        contentView.pickListContent  = [self  getValuesForDependentPickList];
    }
    else if (isRTDependentPicklist && ![parent.fieldAPIName isEqualToString:@"RecordTypeId"])
    {
        contentView.pickListContent = [appDelegate.databaseInterface  getRTPicklistValuesForFieldApiName:parent.fieldAPIName objectApiName:sfmObjectName recordTypeId:recordTypeId];
        
        //9778
        NSMutableArray *sortedPicklistContents = [appDelegate.databaseInterface getSortedRTPicklistValues:contentView.pickListContent fieldApiName:parent.fieldAPIName objectApiName:sfmObjectName];
        
        if ([sortedPicklistContents count]==[contentView.pickListContent count]) {
            contentView.pickListContent =sortedPicklistContents;
        }
        if ([contentView.pickListContent count]>0)
        {
            [contentView.pickListContent removeObjectAtIndex:0];
        }
        
    }
    else
    {
        contentView.pickListContent=pickerContent;
    }
    //5878: Aparna : End here
    if([pickerContent count]>0)
    {
        for (int i=0; i<[pickerContent count]; i++)
        {
            NSString *stringLength=[pickerContent objectAtIndex:i];
            int Length=[stringLength length];
            if(Length >25)
            {
                if(Length >=40)
                {
                    Max_Length=40;
                    break;
                }
                else
                {
                    Max_Length=Length;
                }
            }
            CGSize size=CGSizeMake(0,0);
            if (Max_Length>25)
            {
                size=[stringLength sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(((Max_Length*13)-30),21)];
            }
            else
            {
                size=[stringLength sizeWithFont:[UIFont systemFontOfSize:20] constrainedToSize:CGSizeMake(319,21)];
                
            }
            int max=size.width;
            if(max ==0 && Max_Length>25)
            {
                Max_Length=45;
            }
        }
       
        SMLog(kLogLevelVerbose,@"Multi-Picklist Max Size %d",Max_Length);

    }
    
    contentView.MPickerDelegate=delegate;
    contentView.releasPODelegate=self;
    contentView.lookUp=str;
    
    if(flag == TRUE)
    {
        contentView.flag=TRUE;
        flag=FALSE;
        
    }
    else
    {
        contentView.dictArray=[pickListValues retain];
        
    }
    poc = [[UIPopoverController alloc] initWithContentViewController:contentView];
    poc.delegate = contentView;
    if(Max_Length>25)
    {
        [poc setPopoverContentSize:CGSizeMake(((Max_Length*13)-30), contentView.view.frame.size.height) animated:YES];
    }
    else
    {
        [poc setPopoverContentSize:contentView.view.frame.size animated:YES];
    }
    CGRect rect=CGRectMake(0 , 0, pickerrect.size.width, pickerrect.size.height);
    
    [poc presentPopoverFromRect:rect    inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
-(void) releasPopover
{
    contentView.MPickerDelegate=nil;
    contentView.releasPODelegate=nil;
    [contentView release];
    [poc release];
    
}
-(void)dealloc
{
    
    [super dealloc];
    
}

- (NSArray *)getValuesForDependentPickList
{
   
    BMPTextView * parent = (BMPTextView *)delegate;

    NSUInteger count = [parent.controlDelegate getControlFieldPickListIndexForControlledPicklist:self.controllerName atIndexPath:parent.indexPath controlType:parent.control_type];
    SMLog(kLogLevelVerbose,@"%d", count);
    if(count == 9999999)
    {
        return pickerContent;
    }
    //get the count and
    NSMutableArray * picker_Array = [[NSMutableArray alloc] initWithCapacity:0];
//    [picker_Array addObject:@""];
    @try{
        for(int j = 0 ; j< [self.pickerContent count];j++)
        {
            NSString * obj = [self.validFor objectAtIndex:j];
            obj = [obj stringByReplacingOccurrencesOfString:@" " withString:@""];
            if(obj == nil || [obj isEqualToString:@""])
            {
                // SMLog(kLogLevelVerbose,@" object  %@" , obj);
                continue;
            }
            
            BitSet *bitObj = [[BitSet alloc] initWithString:obj];
            for(int k=0; k< [bitObj size]; k++)
            {
                if(k < count)
                    continue;
                if(( k == count) && ([bitObj testBit:count]))
                {
                    //add to cityData
                    [picker_Array addObject:[self.pickerContent objectAtIndex:j]];
                    break;
                }
            }
            [bitObj release];
            
        }
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name BotSpinnerTextField :getValuesForDependentPickList %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason BotSpinnerTextField :getValuesForDependentPickList %@",exp.reason);
    }
    
    return [picker_Array autorelease];
}

@end

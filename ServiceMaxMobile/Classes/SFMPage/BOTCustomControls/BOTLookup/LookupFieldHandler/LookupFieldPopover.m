//
//  CTextFieldHandlerNeum.m
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupFieldPopover.h"
#import "LookupField.h"
#import "WSInterface.h"
#import "AppDelegate.h"
#import "databaseIntefaceSfm.h"

//extern void NSLog(NSString *format, ...);

@implementation LookupFieldPopover

@synthesize POC;
@synthesize rect;
@synthesize PopOverView;
@synthesize lookupDelegate;
@synthesize lableValue;
@synthesize POView;
@synthesize lookupView;
@synthesize searchId;
@synthesize relatedObjectName;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

- (void) tapLookup:(id)sender
{
    // display lookup popover
    lookupView = [[LookupView alloc] initWithNibName:@"LookupView" bundle:nil];
    lookupView.delegate = self;
    LookupField * lookupField = (LookupField *)lookupDelegate;
    lookupView.objectName = lookupField.objectName;
    lookupView.searchId = lookupField.searchId;
    LookupField * lField = (LookupField*) [sender view];
    
    //Shrinivas
    self.searchId = lField.searchId;
    self.relatedObjectName = lField.objectName;
    

    NSString * searchBarTitle = nil;
    // Obtain Search Bar Title from gFIELD_RELATED_OBJECT_NAME in Describe
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    
    if(appDelegate.isWorkinginOffline)
    {
        NSString *  searchBarTitle  = [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:lookupField.objectName];
        
        if([searchBarTitle isEqualToString:self.lableValue])
        {
            NSString * search = searchBarTitle;
            search = [search  stringByAppendingString:@" Search"];
            lookupView.title = search;
        }
        else
        {
            NSString * title = searchBarTitle;
            title = [title  stringByAppendingString:@" Search For "];
            title = [title stringByAppendingString:lableValue];
            lookupView.title = title;        
        }

    }
    else
    {
        for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
        {
            ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
            if ([[descObj name] isEqualToString:lookupField.objectName])
                searchBarTitle = [NSString stringWithFormat:@"%@", [descObj label]];
        }
        
        if([searchBarTitle isEqualToString:self.lableValue])
        {
            NSString * search = searchBarTitle;
            search = [search  stringByAppendingString:@" Search"];
            lookupView.title = search;
        }
        else
        {
            NSString * title = searchBarTitle;
            title = [title  stringByAppendingString:@" Search For "];
            title = [title stringByAppendingString:lableValue];
            lookupView.title = title;        
        }
    }

    LookupField * parent = (LookupField *)lookupDelegate;
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:lookupView];
    
    popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    [parent.controlDelegate setLookupPopover:popOver];
    
    popOver.delegate = self;
    lookupView.popover = popOver;
	NSInteger height = parent.heightForPopover; //Defect Fix :- 7447

    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        //Defect Fix :- 7447
        [popOver presentPopoverFromRect:CGRectMake(768, height, 10,10) inView:POView permittedArrowDirections:0 animated:YES];
        [popOver release];
    }
    else
    {
        //Defect Fix :- 7447
        [popOver presentPopoverFromRect:CGRectMake(768, height, 10, 10) inView:POView permittedArrowDirections:0 animated:YES];
        [popOver release];
    }

    [parent.controlDelegate controlIndexPath:parent.indexPath];
    [parent.controlDelegate selectControlAtIndexPath:parent.indexPath];
}

-(void) LaunchPopover
{
    LookupField * parent = (LookupField *)lookupDelegate;

    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:lookupView];
    
    popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    [parent.controlDelegate setLookupPopover:popOver];
    
    popOver.delegate = self;
    lookupView.popover = popOver;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [popOver presentPopoverFromRect:CGRectMake(768, 0, 0, 0) inView:POView permittedArrowDirections:0 animated:YES];
        [popOver release];
    }
    else
    {
        [popOver presentPopoverFromRect:CGRectMake(768, 0, 0, 0) inView:POView permittedArrowDirections:0 animated:YES];
        [popOver release];
    }
    
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    [parent.controlDelegate selectControlAtIndexPath:parent.indexPath];
}

#pragma mark - LookupView Delegate Method
- (void) searchObject:(NSString *)keyword withObjectName:(NSString *)objectName returnTo:(id)caller setting:(BOOL)idAvailable
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        //[appDelegate displayNoInternetAvailable];
        return;
    }
	@try{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    keyword = [keyword stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    
    LookupField * lookupField = (LookupField *)lookupDelegate;
    NSString * Field_Lookup_Context_Value = @"";
    
    if (lookupField.selectedIndexPath)
    {
        NSMutableArray * array = [lookupField.Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_values = [array objectAtIndex:lookupField.selectedIndexPath.row-1];
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSDictionary * dict = [detail_values objectAtIndex:i];
            NSString * value_Field_API = [dict objectForKey:gVALUE_FIELD_API_NAME];
            if ([value_Field_API isEqualToString:lookupField.Field_Lookup_Context])
            {
                Field_Lookup_Context_Value = [dict objectForKey:gVALUE_FIELD_VALUE_VALUE];
                break;
            }
        }
    }
    else
    {
        // Header
        BOOL flag = NO;
        NSDictionary * hdr_object = [appDelegate.SFMPage objectForKey:gHEADER];
        NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
        for (int i=0;i<[header_sections count];i++)
        {
            NSDictionary * section = [header_sections objectAtIndex:i];
            NSArray * section_fields = [section objectForKey:@"section_Fields"];
            for (int j = 0; j < [section_fields count]; j++)
            {
                NSDictionary * section_field = [section_fields objectAtIndex:j];
                NSString * value_Field_API = [section_field objectForKey:gFIELD_API_NAME];
                if ([value_Field_API isEqualToString:lookupField.Field_Lookup_Context])
                {
                    Field_Lookup_Context_Value = [section_field objectForKey:gFIELD_VALUE_VALUE];
                    flag = YES;
                    break;
                }
            }
            if (flag)
                break;
        }
    }
    
    [appDelegate.wsInterface getLookUpFieldsWithKeyword:keyword forObject:objectName returnTo:caller setting:idAvailable overrideRelatedLookup:lookupField.Override_Related_Lookup lookupContext:Field_Lookup_Context_Value lookupQuery:lookupField.Field_Lookup_Query];
	}@catch (NSException *exp) {
        NSLog(@"Exception Name LookupFieldPopover :searchObject %@",exp.name);
        NSLog(@"Exception Reason LookupFieldPopover :searchObject %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}
//sahana 23rd sept 2011
- (void) didSelectObject:(NSArray *)lookupObject defaultDisplayColumn:(NSString *)defaultdisplayColumn
{
    if ([lookupDelegate respondsToSelector:@selector(didSelectObject:defaultDisplayColumn:)])
        [lookupDelegate didSelectObject:lookupObject defaultDisplayColumn:defaultdisplayColumn];
    
    LookupField * parent = (LookupField *)lookupDelegate;
    [parent.controlDelegate deselectControlAtIndexPath:parent.indexPath];
    
    [popOver dismissPopoverAnimated:YES];
    [parent.controlDelegate setLookupPopover:nil];
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    LookupField * parent = (LookupField *)lookupDelegate;
    [parent.controlDelegate deselectControlAtIndexPath:parent.indexPath];
    [parent.controlDelegate setLookupPopover:nil];
}

-(void)releasePopOver
{
    [POC release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (void) getSearchIdandObjectName:(NSString *)keyword
{
    NSDictionary *dict;
    dict = [appDelegate.databaseInterface getLookupDataFromDBWith:self.searchId referenceTo:self.relatedObjectName searchFor:keyword withPreFilters:self.lookupView.preFilters andFilters:self.lookupView.advancedFilters];
//    NSLog(@"%@", dict);
    [lookupView setLookupData:dict];
}
-(void) DismissLookupFieldPopover
{
    [lookupView.popover dismissPopoverAnimated:YES];
    LookupField * lookupField = (LookupField *)lookupDelegate;
    [lookupField launchBarcodeScanner];
}

@end

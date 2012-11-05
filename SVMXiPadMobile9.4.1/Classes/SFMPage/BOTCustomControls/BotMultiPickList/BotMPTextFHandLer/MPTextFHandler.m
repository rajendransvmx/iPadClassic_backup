//
//  MPTextFHandler.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MPTextFHandler.h"
#import "BMPTextView.h"

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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BMPTextView * parent = (BMPTextView *)delegate;
    //[parent.controlDelegate controlIndexPath:parent.indexPath];
    
    contentView = [[MPickContent alloc] init];
    //sahana 9th Aug
    contentView.initialString = parent.text;;
    contentView.pickListContent=pickerContent;
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
    [poc setPopoverContentSize:contentView.view.frame.size animated:YES];
    
    CGRect rect=CGRectMake(0 , 0, pickerrect.size.width, pickerrect.size.height);
    
    [poc presentPopoverFromRect:rect    inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    return NO;
    
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

@end

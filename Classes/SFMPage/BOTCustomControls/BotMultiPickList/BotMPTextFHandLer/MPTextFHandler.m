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
extern void SVMXLog(NSString *format, ...);

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BMPTextView * parent = (BMPTextView *)delegate;
    //[parent.controlDelegate controlIndexPath:parent.indexPath];
    
    contentView = [[MPickContent alloc] init];
    //sahana 9th Aug
    contentView.initialString = parent.text;;
    contentView.pickListContent=pickerContent;
    int Max_Length=25;
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
       
        SMLog(@"Multi-Picklist Max Size %d",Max_Length);

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

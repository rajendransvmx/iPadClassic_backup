//
//  LookupField.m
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupField.h"
#import "iServiceAppDelegate.h"

@implementation LookupField

@synthesize controlDelegate;
@synthesize objectName, objectLabel;
@synthesize delegateHandler;
@synthesize lookupHistory;
@synthesize indexPath;
@synthesize lookupValue;
@synthesize fieldAPIName, relatedObjectName;
@synthesize required;
@synthesize control_type;
@synthesize idValue;
@synthesize first_idValue ,searchId;
@synthesize Override_Related_Lookup, Field_Lookup_Context, Field_Lookup_Query;
@synthesize selectedIndexPath;
@synthesize Disclosure_dict;

-(id) initWithFrame:(CGRect)frame labelValue:(NSString *)labelValue inView:(UIView *)poview
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        delegateHandler = [[LookupFieldPopover alloc] init];
        delegateHandler.lookupDelegate = self;
        delegateHandler.POView = poview;
        delegateHandler.rect = frame;
        delegateHandler.lableValue = labelValue;
        
        self.delegate = delegateHandler;
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIImageView * rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lookup_search.png"]];
        self.rightView = rightImageView;
        self.rightViewMode = UITextFieldViewModeAlways;
        [rightImageView release];
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

-(void) dealloc
{
    [super dealloc];
}

- (void) setReadOnly:(BOOL)flag
{
    self.enabled = !flag;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) settextField:(NSString *)value
{
    // Samman - 24 Sep, 2011
    self.text = value;
}

#pragma mark - LookupFieldPopover Delegate Method
- (void) didSelectObject:(NSArray *)lookupObject defaultDisplayColumn:(NSString *)defaultdisplayColumn
{
    NSString * value = nil;
    NSString * id_value = nil;
    BOOL flag = FALSE;
    for (int i = 0; i < [lookupObject count]; i++)
    {
        NSDictionary * dict = [lookupObject objectAtIndex:i];
        NSString * key = [dict objectForKey:@"key"];
        if ([key isEqualToString:@"Id"])
        {
            idValue = [dict objectForKey:@"value"];
            id_value = [dict objectForKey:@"value"];
            break;
        }
    }

    //sahana 23rd sept 2011

    // 1. Get the Default Lookup field value
    NSString * name = @"";
    for (NSDictionary * dict in lookupObject)
    {
        if (![dict isKindOfClass:[NSDictionary class]])
            continue;
        name = [dict objectForKey:@"key"];
        if ([defaultdisplayColumn isEqualToString:name])
        {
            name = [dict objectForKey:@"value"];
            if (![name isKindOfClass:[NSString class]])
                continue;
            flag = TRUE;
            break;
        }
    }

    if([defaultdisplayColumn isEqualToString:@""] || flag == FALSE)
    {
        NSDictionary * dict = [lookupObject objectAtIndex:0];
        name = [dict objectForKey:@"value"];
        if (![name isKindOfClass:[NSString class]])
            name = @"";
    }

    value = name;    

    [self performSelector:@selector(settextField:) withObject:value afterDelay:0];
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:value fieldKeyValue:id_value controlType:self.control_type];

    [self addObjectToHistory:lookupObject withObjectName:value];
    
    [controlDelegate didUpdateLookUp:value fieldApiName:fieldAPIName valueKey:id_value];
}
//sahana Aug 10th
-(void) deleteLookUpTextFieldValue
{
    self.text = @"";
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:self.text fieldKeyValue:self.text controlType:self.control_type];
    //sahana 26th sept 2011
    [controlDelegate didUpdateLookUp:@"" fieldApiName:fieldAPIName valueKey:@""];
}

- (void) addObjectToHistory:(NSArray *)lookupObject withObjectName:(NSString *)value
{
    // Compare and check if an object is already present in the array.
    // If already present then do not add the object
    if (lookupHistory == nil)
        lookupHistory = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Check if lookup already exists. if yes, then DO NOT add lookup object to History
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray * _lookupHistory = [appDelegate.lookupHistory objectForKey:objectName];
    
    BOOL flag = YES;
    
    for (int i = 0; i < [_lookupHistory count]; i++)
    {
        NSArray * lookup = [_lookupHistory objectAtIndex:i];
        for (int j = 0; j < [lookup count]; j++)
        {
            NSDictionary * dict = [lookup objectAtIndex:j];
            NSString * key = [dict objectForKey:@"key"];
            if ([key isEqualToString:@"Name"])
            {
                NSString * lValue = [dict objectForKey:@"value"];
                if ([lValue isEqualToString:value])
                {
                    flag = NO;
                    break;
                }
            }
        }
    }
    
    if (flag)
        [lookupHistory addObject:lookupObject];
    
    [controlDelegate addLookupHistory:lookupHistory forRelatedObjectName:objectName];
}

@end

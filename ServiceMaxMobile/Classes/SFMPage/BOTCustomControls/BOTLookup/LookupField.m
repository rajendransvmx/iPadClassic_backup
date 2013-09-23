//
//  LookupField.m
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupField.h"
#import "AppDelegate.h"
void SMXLog(const char *methodContext,NSString *message);

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
@synthesize barCodeScannedData;
//Defect Fix :- 7447
@synthesize heightForPopover;

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
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:delegateHandler action:@selector(tapLookup:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
        
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
    [barCodeScannedData release];
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
    @try{
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
    }@catch (NSException *exp) {
        SMLog(@"Exception Name LookupField :didSelectObject %@",exp.name);
        SMLog(@"Exception Reason LookupField :didSelectObject %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
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
    @try{
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
	}@catch (NSException *exp) {
	SMLog(@"Exception Name LookupField :addObjectToHistory %@",exp.name);
	SMLog(@"Exception Reason LookupField :addObjectToHistory %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    [controlDelegate addLookupHistory:lookupHistory forRelatedObjectName:objectName];
}
#pragma Zbar delegate Methods
- (void) launchBarcodeScanner
{
    
    // ADD: present a barcode reader that scans from the camera feed
    reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.sfmPageController presentViewController: reader
                                                     animated: YES completion:nil];
    [reader release];
    //[self dismissModalViewControllerAnimated:YES];
    //[delegate DismissLookupFieldPopover];
    SMLog(@"Launch Bar Code Scanner");
}
- (void) imagePickerController: (UIImagePickerController*) readerController
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    @try{
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;

    // EXAMPLE: do something useful with the barcode data
    self.barCodeScannedData = symbol.data;
    self.backgroundColor=[UIColor redColor];
     [reader dismissViewControllerAnimated: YES completion:nil];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:symbol.data afterDelay:0.1f];
	}@catch (NSException *exp) {
	SMLog(@"Exception Name LookupField :imagePickerController %@",exp.name);
	SMLog(@"Exception Reason LookupField :imagePickerController %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

    // EXAMPLE: do something useful with the barcode image
    // ADD: dismiss the controller (NB dismiss from the *reader*!)

}
-(void) DismissBarCodeReader:(NSString *)_text
{
    NSString *_searchText=@"";
    _searchText=[_searchText stringByAppendingFormat:@" %@",_text];
    SMLog(@"Search Text =%@ lenght %d",_searchText,[_searchText length]);
    [delegateHandler LaunchPopover];
    [[self delegateHandler].lookupView updateTxtField:_text];
    SMLog(@"Bar Code Scanned Text=%@",_text);
    [[self delegateHandler].lookupView searchBarCodeScannerData:_searchText];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    SMLog(@"Dismissing Barcode Scanner");
    [reader dismissViewControllerAnimated: YES completion:nil];
    NSString *nilBarcodeData = [NSString stringWithFormat:@" "];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:nilBarcodeData afterDelay:0.1f];
    [[self delegateHandler].lookupView updateTxtField:nilBarcodeData];
    [[self delegateHandler].lookupView searchBarCodeScannerData:nilBarcodeData];

}
- (void) readerControllerDidFailToRead:(ZBarReaderController*)barcodeReader withRetry:(BOOL)retry
{
    SMLog(@"Failed to Scan the Barcode");
    [barcodeReader dismissViewControllerAnimated: YES completion:nil];
    NSString *nilBarcodeData = [NSString stringWithFormat:@" "];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:nilBarcodeData afterDelay:0.1f];
    [[self delegateHandler].lookupView updateTxtField:nilBarcodeData];
    [[self delegateHandler].lookupView searchBarCodeScannerData:nilBarcodeData];

}


@end

//
//  CusTextView.m
//  CustomClassesipad
//
//  Created by Developer on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);

@implementation CusTextView

@synthesize controlDelegate;
@synthesize readOnly;
@synthesize cusTextView;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame lableValue:(NSString *)lableValue
{
    
    self=[super initWithFrame:frame];
    if(self)
    {
        cusTextView = [[CusTextViewHandler alloc] init];
        cusTextView.delegate = self;
        cusTextView.lableValue = lableValue;
        self.backgroundColor=[UIColor whiteColor];
        self.delegate = cusTextView;
        self.scrollEnabled=TRUE;
        self.autoresizesSubviews=YES;
        self.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [self.layer setBackgroundColor:[[UIColor whiteColor]CGColor]];
        [self.layer setBorderWidth:1.0];
        [self.layer setBorderColor:[[UIColor grayColor]CGColor]];
        iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([appDelegate isCameraAvailable])
        {UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 46)];
            barCodeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"accessoryView_bg.png"]];
            UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(676, 4, 72, 37)];
            [barCodeButton setBackgroundImage:[UIImage imageNamed:@"BarCodeButton.png"] forState:UIControlStateNormal];
            barCodeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [barCodeButton addTarget:self 
                              action:@selector(launchBarcodeScanner:) 
                    forControlEvents:UIControlEventTouchUpInside];
            
            [barCodeView addSubview:barCodeButton];
            self.inputAccessoryView = barCodeView;
        }

        
    }
    return self;
}
- (IBAction) launchBarcodeScanner:(id)sender
{
    [self resignFirstResponder];
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;

    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here

    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];

    // present and release the controller
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.sfmPageController presentViewController: reader
                                                     animated: YES completion:nil];
    [reader release];
    SMLog(@"Launch Bar Code Scanner");
}

- (BOOL) getReadOnly
{
    return readOnly;
}
#pragma mark - ZBar Delegate Methods

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
    // Grab the first barcode
        break;
    self.text = symbol.data;
    SMLog(@"symbol.data=%@",symbol.data);
    [self didChangeText:symbol.data];
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated: YES completion:nil];
}

//Siva Manne #3839
- (void) setRequired:(BOOL)_required 
{
    required = _required;
    if (required)
    {
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"required_textarea.png"]];
        [self addSubview: imgView];
        [self sendSubviewToBack: imgView];
        [imgView release];
    }
}

- (void) setReadOnly:(BOOL)flag
{
    self.editable = !flag;
}

-(void)dealloc
{
    [super dealloc];
}

- (void) setShouldResizeAutomatically:(BOOL)_shouldResizeAutomatically
{
    if (!_shouldResizeAutomatically)
        return;
    
    [self sizeToFit];
    
}

#pragma mark - CusTextViewHandler Delegate
- (void) didChangeText:(NSString *)_text
{  
    SMLog(@"%@ %d", _text, [_text length]);
    
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:_text fieldKeyValue:_text controlType:self.control_type];
}

@end

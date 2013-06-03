//
//  CTextField.m
//  CustomClassesipad
//
//  Created by Developer on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);


@implementation CTextField

@synthesize controlDelegate;
@synthesize delegateHandler;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize isinViewMode;
@synthesize control_type;

-(id) initWithFrame:(CGRect)frame lableValue:(NSString *)lableValue controlType:(NSString *)controlType isinViewMode:(BOOL)mode
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Custom initialization
        delegateHandler = [[CTextFieldHandlerNum alloc] init];
        delegateHandler.delegate = self;
        delegateHandler.rect = frame;
        delegateHandler.lableValue = lableValue;
        delegateHandler.control_type = controlType;
        self.delegate = delegateHandler;
        self.isinViewMode = mode;
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.keyboardType = UIKeyboardTypeNumberPad;

        iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([appDelegate isCameraAvailable])
        {
            UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 46)];
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

        /*if([controlType isEqualToString:@"phone"])
        {
           
            
            UIImage * image = [UIImage imageNamed:@"phone.png"];
            UIControl * c = [[UIControl alloc] initWithFrame:(CGRect){CGPointZero, image.size}];
            c.layer.contents = (id)image.CGImage;
            [c addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
            self.rightView = c;
            self.rightViewMode = UITextFieldViewModeAlways;
        }*/
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
#pragma mark - ZBar Delegate Methods

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    self.text= symbol.data;
    SMLog(@"symbol.data=%@",symbol.data);
    [self didChangeText:symbol.data];    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated: YES completion:nil];
}



#pragma mark - CTextFieldHandlerNum Delegate Method
- (void) didChangeText:(NSString *)_text
{
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:_text fieldKeyValue:_text controlType:self.control_type];
}
-(void)imageTapped:(id)sender
{
    if(!isinViewMode)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.text]];
    }
}

@end

//
//  cusTextFieldAlpha.m
//  CustomClassesipad
//
//  Created by Developer on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cusTextFieldAlpha.h"
#import "AppDelegate.h"
/*Accessibility Changes*/
#import "AccessibilityGlobalConstants.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation cusTextFieldAlpha

@synthesize controlDelegate;
@synthesize delegatehandler;
@synthesize indexPath;
@synthesize fieldAPIName;
@synthesize required;
@synthesize control_type;
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
//Keyboard fix for readonly fields
-(id) initWithFrame:(CGRect)frame control_type:(NSString *)_control_type isInViewMode:(BOOL)mode isEditable:(BOOL)isEditable
{
    self = [super initWithFrame:frame];
    if (self)
    {
        delegatehandler = [[AlhaTextHandler alloc] init];
        delegatehandler.popOverView = self;
        delegatehandler.rect = frame;
        delegatehandler.delegate = self;
        delegatehandler.control_type = _control_type;
        delegatehandler.isInViewMode = mode;
        self.delegate  = delegatehandler;
        
        // Custom initialization
       
        self.frame = frame;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.autoresizesSubviews = TRUE;
        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        if ([_control_type isEqualToString:@"email"])
        {
            self.keyboardType = UIKeyboardTypeEmailAddress;
        }
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if([appDelegate isCameraAvailable] && isEditable) //Keyboard fix for readonly fields
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

        /*if ([_control_type isEqualToString:@"email"])
        {
            UIImageView * rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email_icon.png"]];
            self.rightView = rightImageView;
            self.rightViewMode = UITextFieldViewModeAlways;
            [rightImageView release];   
        }*/
        
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selector:) name:UITextFieldTextDidChangeNotification object:self];
    }
    return self;
}

- (void) setRequired:(BOOL)_required
{
    required = _required;
    if (required)
    {
        UIImageView * leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"required.png"]];
		
		//Shrinivas : Linked SFM UI Automation
		leftImageView.isAccessibilityElement = TRUE;
//		[leftImageView setAccessibilityIdentifier:@"required"];
        /*Accessibility changes*/
        [leftImageView setAccessibilityIdentifier:kAccRequiredField];
		
        self.leftView = leftImageView;
        self.leftViewMode = UITextFieldViewModeAlways;
        [leftImageView release];
    }
}

- (void) selector:(NSNotification *) notification
{
    // cusTextFieldAlpha * field = [notification object];
    // SMLog(kLogLevelVerbose,@"%@", field.text);
}

-(void) dealloc
{
    [super dealloc];
}
#pragma mark - Custom Methods
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.sfmPageController presentViewController: reader
                            animated: YES completion:nil];
    [reader release];
    SMLog(kLogLevelVerbose,@"Launch Bar Code Scanner");
}

#pragma mark - ZBar Delegate Methods

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    @try{
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(kLogLevelVerbose,@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    self.text = symbol.data;
    SMLog(kLogLevelVerbose,@"symbol.data=%@",symbol.data);
    [self didChangeText:symbol.data];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated: YES completion:nil];
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name cusTextFieldAlpha :imagePickerController %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason cusTextFieldAlpha :imagePickerController %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

#pragma mark - AlhaTextHandlerDelegate Method

-(void) didChangeText:(NSString *)text
{
    [self.controlDelegate updateDictionaryForCellAtIndexPath:indexPath fieldAPIName:fieldAPIName fieldValue:text fieldKeyValue:text controlType:self.control_type];
}


@end

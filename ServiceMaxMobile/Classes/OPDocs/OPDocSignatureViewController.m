//
//  OPDocSignatureViewController.m
//  iService
//
//  Created by Krishna Shanbhag on 30/05/13.
//
//

#import "OPDocSignatureViewController.h"
#import "SummaryViewController.h"
#import "AppDelegate.h"
#import "NSData-AES.h"

void SMXLog(const char *methodContext,NSString *message);

@interface OPDocSignatureViewController ()

@end

@implementation OPDocSignatureViewController
@synthesize _cancelButt;

@synthesize doneButton;
@synthesize delegate;
@synthesize imageData, parent;

@synthesize signatureName;

//krishnasign
@synthesize signatureDataArray;
#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    
    [signatureName release];
    [cancel_button release];
    [done_button release];
    [doneButton release];
	[cancelButton release];
	[_cancelButt release];
    [signatureDataArray release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [drawImage release];
    drawImage = nil;
    [cancel_button release];
    cancel_button = nil;
    [done_button release];
    done_button = nil;
    [self setDoneButton:nil];
	[cancelButton release];
	cancelButton = nil;
	[self set_cancelButt:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Touches delegate 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
	
    lastPoint = [touch locationInView:self.view];
    lastPoint.y -= 20;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    currentPoint.y -= 20;
    UIGraphicsBeginImageContext(self.view.frame.size);
    [drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 0.7);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!mouseSwiped)
	{
        UIGraphicsBeginImageContext(self.view.frame.size);
        [drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    else {
        isSigned = YES;
    }
}

#pragma mark - Private methods
- (NSString *) getRandomString
{
    NSString *date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSArray *randomArray = [date componentsSeparatedByString:@"."];
    NSString *randomString = nil;
    randomString = [NSString stringWithFormat:@"%@%@",[[randomArray objectAtIndex:0] substringWithRange:
                                                       NSMakeRange(2, 6)],[[randomArray objectAtIndex:1] substringWithRange:NSMakeRange(0, 5)]];
    
    return randomString;
}

- (void) SetImage
{
	if( imageData != nil)
		drawImage.image = [UIImage imageWithData:imageData];
}

- (NSString *) getWrappedStringFromString:(NSString *)data
{
    //NSString *data = [userData text];
    if([data length] == 0)
        return nil;
    //669
    CGSize oldSize = [data sizeWithFont:[UIFont boldSystemFontOfSize:31]
                      constrainedToSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT)
                          lineBreakMode:UILineBreakModeWordWrap];
    
    
    NSString *newData = [data substringToIndex:0];
    
    //Modified Kri - OPDOC-CR
    CGSize newSize = CGSizeZero;
    int position = 0;
    
    while ((MAX_WIDTH-10)> newSize.width)
    {
        
        NSRange range;
        
        range.length = 1;
        
        range.location = position;
        
        oldSize = [newData sizeWithFont:[UIFont boldSystemFontOfSize:31]
                      constrainedToSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT)
                          lineBreakMode:UILineBreakModeWordWrap];
        
        SMLog(@"Range Position = %d Data Length = %d",range.location,[data length]);
        if(range.location >= [data length])
        {
            range.location = 0;
            position = 0;
        }
        newData = [newData stringByAppendingFormat:@"%@",[data substringWithRange:range]];
        newSize = [newData sizeWithFont:[UIFont boldSystemFontOfSize:31]
                      constrainedToSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT)
                          lineBreakMode:UILineBreakModeWordWrap];
        position++;
        if(oldSize.width >= newSize.width)
        {
            break;
        }
        
    }
    
    return newData;
    
}

#pragma mark - View life cycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate * appDelegte = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    isSigned = NO;
    @try
    {
        done_button .titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON];
        cancel_button.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON];
        //	doneButton.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON];
        //	cancelButton.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON];
        [doneButton setTitle:[appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON] forState:UIControlStateNormal];
        [_cancelButt setTitle:[appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON] forState:UIControlStateNormal];
        
        
        // ################################ //
        // Fill the marker with marker text
        
        NSDictionary * dict = [appDelegte.SFMPage objectForKey:gHEADER];
        NSString * objectName = [dict objectForKey:@"hdr_Object_Name"];
        NSString * objName = [appDelegte.calDataBase getNameForSignature:objectName andId:appDelegte.sfmPageController.recordId];
        
        if ([objName isEqualToString:@""])
        {
            //objName = [appDelegte.calDataBase getObjectLabel:objectName];
            //objName = [objName stringByAppendingString:@"-local"];
            objName = [self getRandomString];
        }
        
        NSDate * today = [NSDate date];
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:TIMEFORMAT];
        //Optionally for time zone converstions
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSString *stringFromDate = [dateFormatter stringFromDate:today];
        
        [dateFormatter release];
        
        NSString * string = [NSString stringWithFormat:@"%@ %@ ", objName, stringFromDate];
        string=[self getWrappedStringFromString:string];
        
        NSMutableString * markerString = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < 10; i++)
        {
            [markerString appendString:string];
            [markerString appendString:@"\n"];
        }
        watermark.text = markerString;
	}@catch (NSException *exp) {
        SMLog(@"Exception Name SignatureViewController :viewDidLoad %@",exp.name);
        SMLog(@"Exception Reason SignatureViewController :viewDidLoad %@",exp.reason);
    }
    // ################################ //
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Button actions
- (IBAction) Cancel
{
    [delegate setSignImageData:nil withSignId:nil andSignName:nil];
	[self.view removeFromSuperview];
}

- (IBAction) Done
{
    //just save the signature images, do not upload.

    int timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *signatureTextName = [NSString stringWithFormat:@"%@_%d",self.signatureName,timeStamp];
    
    if(isSigned) {
        [watermarkedSignature bringSubviewToFront:watermark];
        
        CALayer *someLayer = [watermarkedSignature layer];
        [someLayer setRasterizationScale:0.5];
        [someLayer setShouldRasterize:YES];
        
        CGSize size = [watermarkedSignature bounds].size;//[someImageView bounds].size;
        UIGraphicsBeginImageContext(size);
        
        CGContextRef cgContextNew = UIGraphicsGetCurrentContext();
        [someLayer renderInContext:cgContextNew];
        UIImage *newImage1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageDataNew = UIImagePNGRepresentation(newImage1);
        
        encryptedImageData = [imageDataNew AESEncryptWithPassphrase:@"hello123_!@#$%^&*()"];
            //krishna opdoc signatureName    
        [delegate setSignImageData:encryptedImageData withSignId:self.signatureName andSignName:signatureTextName];
        
    }
    else {
//        NSString *imageInfoId = [signDict objectForKey:@"ImageId"];
        [appDelegate.calDataBase deleteOPDocSignatureForSignId:self.signatureName andSignType:@"OPDOC"];
        //krishna opdoc sign
        [delegate setSignImageData:nil withSignId:nil andSignName:nil];
    }
    [appDelegate excludeDocumentsDirFilesFromBackup];
	[self.view removeFromSuperview];
}

- (IBAction) Erase
{
	drawImage.image = nil;
    isSigned = NO;
}


@end
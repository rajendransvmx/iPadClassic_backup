//
//  SmartDocsSignatureViewController.m
//  iService
//
//  Created by Krishna Shanbhag on 30/05/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "SmartDocsSignatureViewController.h"
#import "NSData-AES.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@interface SmartDocsSignatureViewController ()

@end

@implementation SmartDocsSignatureViewController

@synthesize delegate;
@synthesize imageData, parent;
@synthesize signatureName;
@synthesize signatureDataArray;

#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    _drawImage = nil;
    _doneButton = nil;
	_cancelButton = nil;
    [super viewDidUnload];
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
    [self.drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 0.7);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!mouseSwiped)
	{
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        
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

- (void)setImage
{
	if( imageData != nil)
		self.drawImage.image = [UIImage imageWithData:imageData];
}

- (NSString *) getWrappedStringFromString:(NSString *)data
{
    //NSString *data = [userData text];
    if([data length] == 0)
        return nil;
    //669
    CGSize oldSize = [data sizeWithFont:[UIFont boldSystemFontOfSize:31]
                      constrainedToSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT)
                          lineBreakMode:NSLineBreakByWordWrapping];
    
    
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
                          lineBreakMode:NSLineBreakByWordWrapping];
        
        if(range.location >= [data length])
        {
            range.location = 0;
            position = 0;
        }
        
        newData = [newData stringByAppendingFormat:@"%@",[data substringWithRange:range]];
        
        newSize = [newData sizeWithFont:[UIFont boldSystemFontOfSize:31]
                      constrainedToSize:CGSizeMake(MAX_WIDTH, MAX_HEIGHT)
                          lineBreakMode:NSLineBreakByWordWrapping];
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

    isSigned = NO;
    @try
    {
        [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        
        // drop shadow
        [self.titleBackground.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.titleBackground.layer setShadowOpacity:0.5];
        [self.titleBackground.layer setShadowRadius:1.0];
        [self.titleBackground.layer setShadowOffset:CGSizeMake(0.0, 2.0)];
        
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
        self.watermark.text = markerString;
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name SignatureViewController :viewDidLoad %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason SignatureViewController :viewDidLoad %@",exp.reason);
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
- (IBAction)cancel:(id)sender
{
    [delegate setSignImageData:nil withSignId:nil andSignName:nil];
	[self.view removeFromSuperview];
}

- (IBAction)done:(id)sender
{
    //just save the signature images, do not upload.

    int timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *signatureTextName = [NSString stringWithFormat:@"%@_%d",self.signatureName,timeStamp];
    
    if(isSigned) {
        [self.watermarkedSignature bringSubviewToFront:self.watermark];
        
        CALayer *someLayer = [self.watermarkedSignature layer];
        [someLayer setRasterizationScale:0.5];
        [someLayer setShouldRasterize:YES];
        
        CGSize size = [self.watermarkedSignature bounds].size;//[someImageView bounds].size;
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
        //krishna opdoc sign. Earlier without a signature if Done is tapped, then we were deleting the old signature file.
        //Now we retain the old signature
        [delegate setSignImageData:nil withSignId:nil andSignName:nil];
    }
    [appDelegate excludeDocumentsDirFilesFromBackup];
	[self.view removeFromSuperview];
}

- (IBAction)erase:(id)sender
{
	self.drawImage.image = nil;
    isSigned = NO;
}


@end
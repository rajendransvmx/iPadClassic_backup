//
//  OPDocSignatureViewController.m
//  iService
//
//  Created by Krishna Shanbhag on 30/05/13.
//
//

#import "OPDocSignatureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData-AES.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@interface OPDocSignatureViewController ()

@end

@implementation OPDocSignatureViewController
{
    CGPoint lastPoint;
}

#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    self.drawImage = nil;
	self.cancelButton = nil;
    self.doneButton = nil;
    
    [super viewDidUnload];
}

#pragma mark - Touches delegate 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
	
    lastPoint = [touch locationInView:self.drawImage];
//    lastPoint.y -= 20;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.drawImage];
//    currentPoint.y -= 20;
    UIGraphicsBeginImageContext(self.drawImage.frame.size);
    [self.drawImage.image drawInRect:CGRectMake(0, 0, self.drawImage.frame.size.width, self.drawImage.frame.size.height)];
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
    if(!self.mouseSwiped)
	{
        UIGraphicsBeginImageContext(self.drawImage.frame.size);
        [self.drawImage.image drawInRect:CGRectMake(0, 0, self.drawImage.frame.size.width, self.drawImage.frame.size.height)];
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
        self.isSigned = YES;
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
	if( self.imageData != nil)
		self.drawImage.image = [UIImage imageWithData:self.imageData];
}

- (NSString *)getWrappedStringFromString:(NSString *)data
{
    //NSString *data = [userData text];
    if([data length] == 0)
        return nil;
    
    UIFont *font = [UIFont boldSystemFontOfSize:21];
    
    CGSize constraint = CGSizeMake(MAX_WIDTH, MAX_HEIGHT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentRight;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    //    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect oldRect = [data boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:attributes
                                        context:nil];
    
    CGSize oldSize = CGSizeMake(oldRect.size.width, oldRect.size.height);
    
    
    NSString *newData = [data substringToIndex:0];
    
    //Modified Kri - OPDOC-CR
    CGSize newSize = CGSizeZero;
    int position = 0;
    
    while ((MAX_WIDTH-10)> newSize.width)
    {
        
        NSRange range;
        
        range.length = 1;
        
        range.location = position;
        
        oldRect = [newData boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:attributes
                                        context:nil];
        oldSize = CGSizeMake(oldRect.size.width, oldRect.size.height);
        
//        NSLog(@"Range Position = %lu Data Length = %lu",(unsigned long)range.location,(unsigned long)[data length]);
        if(range.location >= [data length])
        {
            range.location = 0;
            position = 0;
        }
        newData = [newData stringByAppendingFormat:@"%@",[data substringWithRange:range]];
        
        
        
        oldRect = [newData boundingRectWithSize:constraint
                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     attributes:attributes
                                        context:nil];
        newSize = CGSizeMake(oldRect.size.width, oldRect.size.height);
        
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
        
    self.isSigned = NO;
    @try
    {
        NSDate * today = [NSDate date];
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:TIMEFORMAT];
        //Optionally for time zone converstions
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSString *stringFromDate = [dateFormatter stringFromDate:today];
        
        
        NSString * string = [NSString stringWithFormat:@"%@ %@ ", @"WORK-ORDER", stringFromDate];
        string=[self getWrappedStringFromString:string];
        
        NSMutableString * markerString = [[NSMutableString alloc] initWithCapacity:0];
        for (int i = 0; i < 10; i++)
        {
            [markerString appendString:string];
            [markerString appendString:@"\n"];
        }
        self.watermark.text = markerString;
        
        
        // border radius
        [self.drawImage.layer setCornerRadius:5.0f];
        
        // border
        [self.drawImage.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.drawImage.layer setBorderWidth:1.0f];
        

	}
    @catch (NSException *exp) {
        NSLog(@"Watermark text creation failed!");
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
    [self.delegate setSignImageData:nil withSignId:nil andSignName:nil];
	[self.view removeFromSuperview];
}


- (IBAction)done:(id)sender
{
    //just save the signature images, do not upload.

    int timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *signatureTextName = [NSString stringWithFormat:@"%@_%d",self.signatureName,timeStamp];
    
    if(self.isSigned) {
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
        
        self.encryptedImageData = [imageDataNew AESEncryptWithPassphrase:@"hello123_!@#$%^&*()"];
            //krishna opdoc signatureName    
        [self.delegate setSignImageData:self.encryptedImageData withSignId:self.signatureName andSignName:signatureTextName];
        
    }
    else { 
        //krishna opdoc sign. Earlier without a signature if Done is tapped, then we were deleting the old signature file.
        //Now we retain the old signature
        [self.delegate setSignImageData:nil withSignId:nil andSignName:nil];
    }
    
//    [appDelegate excludeDocumentsDirFilesFromBackup]; // TODO
    
	[self.view removeFromSuperview];
}


- (IBAction)erase:(id)sender
{
	self.drawImage.image = nil;
    self.isSigned = NO;
}

- (void)setImage
{
    if( self.imageData != nil)
        self.drawImage.image = [UIImage imageWithData:self.imageData];
}

@end

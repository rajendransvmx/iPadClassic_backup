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
#import "OPDocViewController.h"
#import "StyleManager.h"

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
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 67/255.0, 67/255.0, 67/255.0, 1.0);
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
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 67/255.0, 67/255.0, 67/255.0, 1.0);
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

- (void) SetImage
{
	if( self.imageData != nil)
		self.drawImage.image = [UIImage imageWithData:self.imageData];
}


- (void)setDataSource:(id<OPDocSignatureDataSource>)dataSource
{
    _dataSource =  dataSource;
    
    if([self.dataSource respondsToSelector:@selector(getWaterMarktext)])
    {
        self.watermark.font = [UIFont boldSystemFontOfSize:26];
        self.watermark.text = [self.dataSource getWaterMarktext];
    }
    
}

#pragma mark - View life cycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.isSigned = NO;
    @try
    {
        
        self.doneButton.tintColor = [UIColor navBarBG];
        self.cancelButton.tintColor = [UIColor navBarBG];
        
        // border radius
        [self.drawImage.layer setCornerRadius:5.0f];
        
        // border
        [self.drawImage.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.drawImage.layer setBorderWidth:1.0f];
        

        self.titleBG.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
        [self.titleBG.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.titleBG.layer setShadowOpacity:0.6];
        [self.titleBG.layer setShadowRadius:0.5f];
        [self.titleBG.layer setShadowOffset:CGSizeMake(0.0, 0.5)];

        
	}
    @catch (NSException *exp) {
        SXLogError(@"Watermark text creation failed!");
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
/**
 * @name cancel:
 *
 * @author Damodar Shenoy
 *
 * @brief Cancels button action : The drawn signature clears the canvas and removes the signature view from superview
 *
 * \par
 *
 * @param  Button sender
 * @return IBAction
 *
 */
- (IBAction)cancel:(id)sender
{
    [self.delegate setSignImageData:nil withSignId:nil andSignName:nil];
	[self.view removeFromSuperview];
}

/**
 * @name done:
 *
 * @author Damodar Shenoy
 *
 * @brief Button Action : Initiates teh signature save process
 *
 * \par
 *
 * @param  Button sender
 * @return IBAction
 *
 */
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


/**
 * @name erase
 *
 * @author Damodar Shenoy
 *
 * @brief Button action : Clears the canvas
 *
 * \par
 *
 * @param  Button sender
 * @return IBAction
 *
 */
- (IBAction)erase:(id)sender
{
	self.drawImage.image = nil;
    self.isSigned = NO;
}


/**
 * @name setImage
 *
 * @author Damodar Shenoy
 *
 * @brief Sets the signature to imageview after watermarking
 *
 * \par
 *
 * @param  nil
 * @return void
 *
 */
- (void)setImage
{
    if( self.imageData != nil)
        self.drawImage.image = [UIImage imageWithData:self.imageData];
}

@end

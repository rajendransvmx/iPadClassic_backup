//
//  SignatureViewController.m
//  Debriefing
//
//  Created by Sanchay on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SignatureViewController.h"
#import "SummaryViewController.h"
#import "iServiceAppDelegate.h"
#import "NSData-AES.h"

@implementation SignatureViewController

@synthesize delegate;
@synthesize imageData, parent;

- (IBAction) Cancel
{
    [delegate setSignImageData:nil];
	[self.view removeFromSuperview];
}

- (IBAction) Done
{
    [watermarkedSignature bringSubviewToFront:watermark];
    
    CGSize size = [watermarkedSignature bounds].size;
    UIGraphicsBeginImageContext(size);
    CALayer * ourLayer = [watermarkedSignature layer];
    
    // Blur
    [ourLayer setRasterizationScale:0.5];
    [ourLayer setShouldRasterize:YES];
    
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    [ourLayer renderInContext:cgContext];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	imageData = UIImagePNGRepresentation(newImage);
	parent.signimagedata = imageData;
    
    encryptedImageData = [imageData AESEncryptWithPassphrase:@"hello123_!@#$%^&*()"];
    
    parent.encryptedImage = encryptedImageData;
    
    // Create BLOB here and save it to the database.
    
    // Save signature to "signature.png" in Documents directory. Always overwrite this one.
 /*   NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];	
    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"customer_signature.png"];

    [fileManager createFileAtPath:filePath contents:imageData attributes:nil]; */
    
	[parent SignatureDone];
    [delegate setSignImageData:encryptedImageData];
	[self.view removeFromSuperview];
}

- (IBAction) Erase
{
	drawImage.image = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2)
	{
        drawImage.image = nil;
        return;
    }
	
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
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2)
	{
        drawImage.image = nil;
        return;
    }
    
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
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    iServiceAppDelegate * appDelegte = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    done_button .titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON];
    cancel_button.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON];
    
    // ################################ //
    // Fill the marker with marker text
    
    NSDictionary * dict = [appDelegte.SFMPage objectForKey:gHEADER];
    NSDictionary * headerData = [dict objectForKey:gHEADER_DATA];
    NSString * objName = [self getObjectNameFromHeaderDataForSignature:headerData forKey:gName];  
    
    NSDate * today = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIMEFORMAT];    
    //Optionally for time zone converstions
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [dateFormatter stringFromDate:today];
    
    [dateFormatter release];

    NSString * string = [NSString stringWithFormat:@"%@ %@", objName, stringFromDate];
    
    NSMutableString * markerString = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < 100; i++)
    {
        [markerString appendString:string];
    }
    watermark.text = markerString;
    // ################################ //
}

- (void) SetImage
{
	if( imageData != nil)
		drawImage.image = [UIImage imageWithData:imageData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload 
{
    [drawImage release];
    drawImage = nil;
    [cancel_button release];
    cancel_button = nil;
    [done_button release];
    done_button = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [cancel_button release];
    [done_button release];
    [super dealloc];
}

#pragma mark - Get headerName
- (NSString *) getObjectNameFromHeaderDataForSignature:(NSDictionary *)dictionary forKey:(NSString *)key
{
    NSArray * allKeys = [dictionary allKeys];
    for (NSString * _key in allKeys)
    {
        NSString * uppercaseKey = [_key uppercaseString];
        NSString * argKey = [key uppercaseString];
        
        if ([uppercaseKey isEqualToString:argKey])
        {
            // Found correct key, retrieve value for key and return
            
            return [dictionary objectForKey:_key];
        }
    }
    
    return @"";
}

@end

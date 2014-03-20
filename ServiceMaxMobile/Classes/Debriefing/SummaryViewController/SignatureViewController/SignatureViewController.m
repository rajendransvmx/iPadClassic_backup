//
//  SignatureViewController.m
//  Debriefing
//
//  Created by Sanchay on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SignatureViewController.h"
#import "SummaryViewController.h"
#import "AppDelegate.h"
#import "NSData-AES.h"
void SMXLog(const char *methodContext,NSString *message);

@implementation SignatureViewController
@synthesize _cancelButt;

@synthesize doneButton;
@synthesize delegate;
@synthesize imageData, parent;

- (IBAction) Cancel
{
    [delegate setSignImageData:nil];
	[self.view removeFromSuperview];
    [self updateAccessibilityValue];
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
    
    parent.encryptedImage = [imageData AESEncryptWithPassphrase:@"hello123_!@#$%^&*()"];
    
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
    [self updateAccessibilityValue];
}

- (IBAction) Erase
{
	drawImage.image = nil;
    [self updateAccessibilityValue];
}

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
    [self updateAccessibilityValue];
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
    [drawImage setIsAccessibilityElement:YES];
    [drawImage setAccessibilityIdentifier:@"SigntaureImageView"];
    AppDelegate * appDelegte = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    @try
    {
    done_button .titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON];
    cancel_button.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON];
//	doneButton.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON];
//	cancelButton.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON];
	[doneButton setTitle:[appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON] forState:UIControlStateNormal];
	[_cancelButt setTitle:[appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON] forState:UIControlStateNormal];
	
	//Defect Fix :- 7454
	[done_button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	done_button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	[_cancelButt.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	_cancelButt.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;

    
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
    [watermark setIsAccessibilityElement:YES];//BOT_TA
    [watermark setAccessibilityLabel:@"WaterMark"];//BOT_TA

	}@catch (NSException *exp) {
	SMLog(@"Exception Name SignatureViewController :viewDidLoad %@",exp.name);
	SMLog(@"Exception Reason SignatureViewController :viewDidLoad %@",exp.reason);
    }
    // ################################ //
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
    
    CGSize newSize;
    
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

- (void) SetImage
{
	if( imageData != nil)
		drawImage.image = [UIImage imageWithData:imageData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
    [self setDoneButton:nil];
	[cancelButton release];
	cancelButton = nil;
	[self set_cancelButt:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [cancel_button release];
    [done_button release];
    [doneButton release];
	[cancelButton release];
	[_cancelButt release];
    [super dealloc];
}

- (NSString *) getRandomString
{
    NSString *date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSArray *randomArray = [date componentsSeparatedByString:@"."];
    NSString *randomString = nil;
    randomString = [NSString stringWithFormat:@"%@%@",[[randomArray objectAtIndex:0] substringWithRange:
                                                       NSMakeRange(2, 6)],[[randomArray objectAtIndex:1] substringWithRange:NSMakeRange(0, 5)]];
    
    return randomString;
}
- (void) updateAccessibilityValue
{
    [drawImage setIsAccessibilityElement:YES];
    [drawImage setAccessibilityIdentifier:@"SigntaureImageView"];
    NSData *theImgData = UIImagePNGRepresentation(drawImage.image);
    NSUInteger theDataSize = [theImgData length];
    NSNumber *thenum = [NSNumber numberWithUnsignedInteger:theDataSize];
    NSMutableDictionary *theValDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [theValDict setObject:thenum forKey:@"DataSize"];
    SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
    NSString *json = [writer stringWithObject:theValDict];
    drawImage.accessibilityValue = json;
}
@end

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
	imageData = UIImagePNGRepresentation(drawImage.image);
	parent.signimagedata = imageData;
    // Save signature to "signature.png" in Documents directory. Always overwrite this one.
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *saveDirectory = [paths objectAtIndex:0];	
    NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"customer_signature.png"];

    [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
    
	[parent SignatureDone];
    [delegate setSignImageData:imageData];
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
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
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
    iServiceAppDelegate * appDelegte = [[UIApplication sharedApplication] delegate];
    
    done_button .titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_DONE_BUTTON];
    cancel_button.titleLabel.text = [appDelegte.wsInterface.tagsDictionary objectForKey:SFM_SIGNATURE_CANCEL_BUTTON];

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


@end

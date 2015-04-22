//
//  SignatureViewController.h
//  Debriefing
//
//  Created by Sanchay on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SummaryViewController;

@protocol SignatureDelegate;

#define TIMEFORMAT          @"EEE,dd MMM yyyy hh:mm:ss a"
#define MAX_WIDTH           665
#define MAX_HEIGHT          378

@interface SignatureViewController : UIViewController
{
    id <SignatureDelegate> delegate;
	IBOutlet UIImageView *drawImage;

	BOOL mouseSwiped;
	CGPoint lastPoint;

	NSData *imageData, * encryptedImageData;
	
	SummaryViewController *parent;
    
    IBOutlet UIButton * cancel_button;
    IBOutlet UIButton *done_button;
    
	IBOutlet UIButton *cancelButton;
    IBOutlet UIView * watermarkedSignature;
    IBOutlet UITextView * watermark;
    /*Accessibility changes*/
    IBOutlet UIButton *eraseSignature;
}
@property (retain, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, assign) id <SignatureDelegate> delegate;

@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) SummaryViewController *parent;

- (IBAction) Cancel;
- (IBAction) Done;
- (IBAction) Erase;
- (void) SetImage;
@property (retain, nonatomic) IBOutlet UIButton *_cancelButt;
- (NSString *) getRandomString;
- (NSString *) getWrappedStringFromString:(NSString *)data;
- (void) updateAccessibilityValue;
@end

@protocol SignatureDelegate <NSObject>

@optional
- (void) setSignImageData:(NSData *)imageData;

@end

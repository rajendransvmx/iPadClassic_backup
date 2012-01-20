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
    
    IBOutlet UIView * watermarkedSignature;
    IBOutlet UITextView * watermark;
}

@property (nonatomic, assign) id <SignatureDelegate> delegate;

@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) SummaryViewController *parent;

- (IBAction) Cancel;
- (IBAction) Done;
- (IBAction) Erase;
- (void) SetImage;
- (NSString *) getObjectNameFromHeaderDataForSignature:(NSDictionary *)dictionary forKey:(NSString *)key;

@end

@protocol SignatureDelegate <NSObject>

@optional
- (void) setSignImageData:(NSData *)imageData;

@end

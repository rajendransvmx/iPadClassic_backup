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

@interface SignatureViewController : UIViewController
{
    id <SignatureDelegate> delegate;
	IBOutlet UIImageView *drawImage;

	BOOL mouseSwiped;
	CGPoint lastPoint;

	NSData *imageData;
	
	SummaryViewController *parent;
    
    IBOutlet UIButton * cancel_button;
    IBOutlet UIButton *done_button;
}

@property (nonatomic, assign) id <SignatureDelegate> delegate;

@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) SummaryViewController *parent;

- (IBAction) Cancel;
- (IBAction) Done;
- (IBAction) Erase;
- (void) SetImage;

@end

@protocol SignatureDelegate <NSObject>

@optional
- (void) setSignImageData:(NSData *)imageData;

@end

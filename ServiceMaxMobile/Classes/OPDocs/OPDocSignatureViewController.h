//
//  OPDocSignatureViewController.h
//  iService
//
//  Created by Krishna Shanbhag on 30/05/13.
//
//

#import <UIKit/UIKit.h>

@class OPDocViewController;

@protocol opDocSignatureDelegate;

#define TIMEFORMAT          @"EEE,dd MMM yyyy hh:mm:ss a"
#define MAX_WIDTH           665
#define MAX_HEIGHT          378

@interface OPDocSignatureViewController : UIViewController
{
    id <opDocSignatureDelegate> delegate;
	IBOutlet UIImageView *drawImage;
    
	BOOL mouseSwiped;
	CGPoint lastPoint;
    
	NSData *imageData, * encryptedImageData;
	
	OPDocViewController *parent;
    
    IBOutlet UIButton * cancel_button;
    IBOutlet UIButton *done_button;
    
	IBOutlet UIButton *cancelButton;
    IBOutlet UIView * watermarkedSignature;
    IBOutlet UITextView * watermark;
    
    BOOL isSigned;
    
    /*Accessibility changes*/
    IBOutlet UIButton * erase;
    
}
//krishnasign
@property (retain, nonatomic) NSMutableArray        *signatureDataArray;


@property (retain, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, assign) id <opDocSignatureDelegate> delegate;

@property (nonatomic, retain) NSData *imageData;
@property (nonatomic, retain) OPDocViewController *parent;

@property (nonatomic, retain) NSString *signatureName;

- (IBAction) Cancel;
- (IBAction) Done;
- (IBAction) Erase;
- (void) SetImage;
@property (retain, nonatomic) IBOutlet UIButton *_cancelButt;
- (NSString *) getRandomString;
- (NSString *) getWrappedStringFromString:(NSString *)data;

@end

@protocol opDocSignatureDelegate <NSObject>

@optional
//krishna opdoc signatureName
- (void) setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName;

@end

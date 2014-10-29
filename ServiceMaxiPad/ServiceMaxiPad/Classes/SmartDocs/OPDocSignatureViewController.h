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
    
@property (nonatomic, assign) BOOL mouseSwiped;

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) NSData *encryptedImageData;
	
@property (nonatomic, assign) BOOL isSigned;

@property (nonatomic, assign) OPDocViewController *parent;

@property (nonatomic, assign) id <opDocSignatureDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *signatureDataArray;
@property (nonatomic, strong) NSString *signatureName;

@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIView * watermarkedSignature;
@property (strong, nonatomic) IBOutlet UITextView * watermark;
@property (strong, nonatomic) IBOutlet UIImageView *drawImage;



- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)erase:(id)sender;

- (void)setImage;

- (NSString *) getRandomString;
- (NSString *) getWrappedStringFromString:(NSString *)data;

@end

@protocol opDocSignatureDelegate <NSObject>

@optional
//krishna opdoc signatureName
- (void) setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName;

@end

//
//  OPDocSignatureViewController.h
//  iService
//
//  Created by Krishna Shanbhag on 30/05/13.
//
//

#import <UIKit/UIKit.h>

@class OPDocViewController;

@protocol OPDocSignatureDelegate;
@protocol OPDocSignatureDataSource;

#define TIMEFORMAT          @"EEE,dd MMM yyyy hh:mm:ss a"
#define MAX_WIDTH           539
#define MAX_HEIGHT          258

@interface OPDocSignatureViewController : UIViewController
    
@property (nonatomic, assign) BOOL mouseSwiped;

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) NSData *encryptedImageData;
	
@property (nonatomic, assign) BOOL isSigned;

@property (nonatomic, assign) OPDocViewController *parent;

@property (nonatomic, assign) id <OPDocSignatureDelegate> delegate;
@property (nonatomic, assign) id <OPDocSignatureDataSource> dataSource;

@property (strong, nonatomic) NSMutableArray *signatureDataArray;
@property (nonatomic, strong) NSString *signatureName;

@property (strong, nonatomic) IBOutlet UIView *titleBG;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIView * watermarkedSignature;
@property (strong, nonatomic) IBOutlet UITextView * watermark;
@property (strong, nonatomic) IBOutlet UIImageView *drawImage;
@property (strong, nonatomic) IBOutlet UIView *drawView;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)erase:(id)sender;

- (void)setImage;

- (NSString *) getRandomString;
- (NSString *) getWrappedStringFromString:(NSString *)data;

@end

@protocol OPDocSignatureDelegate <NSObject>

@optional
//krishna opdoc signatureName
- (void) setSignImageData:(NSData *)imageData withSignId:(NSString *)signId andSignName:(NSString *)signName;

@end

@protocol OPDocSignatureDataSource <NSObject>

@optional

@required
- (NSString*)getWaterMarktext;

@end


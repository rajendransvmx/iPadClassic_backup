//
//  OPDocViewController.h
//  iService
//
//  Created by Damodar on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "JSExecuter.h"
#import "OPDocTemplateSelectorViewController.h"
#import "SignatureViewController.h"
#import "PDFCreator.h"
#import "OPDocSignatureViewController.h"


@interface OPDocViewController : UIViewController <UINavigationControllerDelegate,JSExecuterDelegate,UIPopoverControllerDelegate, loadDocTemplate, opDocSignatureDelegate> {
    
    UIPopoverController *popOver;

    OPDocSignatureViewController *sign;
    NSData *signimagedata;
    BOOL isShowingSignatureCapture;
    BOOL ifFileAvailable;
    NSString *existingFilePath;
}
@property (nonatomic, retain) NSArray *signatureArray;
@property (nonatomic, retain) NSString *signEventName;
@property (nonatomic, retain) NSString *signEventParameterString;

@property (nonatomic, copy)  NSString            *opdocTitleString;
@property (nonatomic, retain)JSExecuter          *jsExecuter;
@property (nonatomic, copy)  NSString            *recordIdentifier;
@property (nonatomic, copy)  NSString            *processIdentifier;

//krishna OPDoc offfline generation
@property (nonatomic, copy) NSString             *localIdentifier;

//krishna opdoc sign info
@property (nonatomic, retain) NSMutableDictionary       *signatureInfoDict;

//@property (nonatomic, retain) UIPopoverController *popOver;

- (void)addJsExecuterToView;
- (void) setTitleForOutputDocs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRecordId:(NSString *)recordId andProcessId:(NSString *)processId andLocalId:(NSString *)localid;
- (void)captureSignature;

- (void)finalizeAndStoreHTML:(NSDictionary *)finalizeDict;

@end

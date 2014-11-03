//
//  OPDocViewController.h
//  iService
//
//  Created by Damodar on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "JSExecuter.h"
#import "OPDocSignatureViewController.h"


@interface OPDocViewController : UIViewController <UINavigationControllerDelegate,JSExecuterDelegate,UIPopoverControllerDelegate, opDocSignatureDelegate> {
    
    UIPopoverController *popOver;

    OPDocSignatureViewController *sign;
    NSData *signimagedata;
    BOOL isShowingSignatureCapture;
    BOOL ifFileAvailable;
    NSString *existingFilePath;
}
@property (nonatomic, strong) NSArray *signatureArray;
@property (nonatomic, strong) NSString *signEventName;
@property (nonatomic, strong) NSString *signEventParameterString;

@property (nonatomic, copy)  NSString            *opdocTitleString;
@property (nonatomic, strong)JSExecuter          *jsExecuter;
@property (nonatomic, copy)  NSString            *recordIdentifier;
@property (nonatomic, copy)  NSString            *processIdentifier;

//krishna OPDoc offfline generation
@property (nonatomic, copy) NSString             *localIdentifier;

//krishna opdoc sign info
@property (nonatomic, strong) NSMutableDictionary       *signatureInfoDict;

//@property (nonatomic, strong) UIPopoverController *popOver;

- (void)addJsExecuterToView;
- (void) setTitleForOutputDocs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forRecordId:(NSString *)recordId andProcessId:(NSString *)processId andLocalId:(NSString *)localid;
- (void)captureSignature;

- (void)finalizeAndStoreHTML:(NSDictionary *)finalizeDict;

@end

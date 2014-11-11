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


@interface OPDocViewController : UIViewController <UINavigationControllerDelegate,JSExecuterDelegate,UIPopoverControllerDelegate, OPDocSignatureDelegate, OPDocSignatureDataSource> {
    
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
@property (nonatomic, copy)  NSString            *objectName;
@property (nonatomic, copy)  NSString            *recordIdentifier;
@property (nonatomic, copy)  NSString            *processIdentifier;
@property (nonatomic, copy)  NSString            *processSFID;

//krishna OPDoc offfline generation
@property (nonatomic, copy) NSString             *localIdentifier;

//krishna opdoc sign info
@property (nonatomic, strong) NSMutableDictionary       *signatureInfoDict;

//@property (nonatomic, strong) UIPopoverController *popOver;

- (void)addJsExecuterToView;
- (void) setTitleForOutputDocs;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forObject:(NSString*)objectName forRecordId:(NSString *)recordId andLocalId:(NSString *)localid andProcessId:(NSString *)processId andProcessSFId:(NSString *)pSFId;
- (void)captureSignature;

- (void)finalizeAndStoreHTML:(NSDictionary *)finalizeDict;

@end

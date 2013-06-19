//
//  PDFCreator.h
//  PDFCreator
//
//  Created by Samman Banerjee on 25/10/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKQueryResult.h"
#import <MessageUI/MessageUI.h>
#import "MessageUI/MFMailComposeViewController.h"
#import "iOSInterfaceObject.h"
#include <CoreText/CoreText.h>

@protocol PDFCreatorDelegate

@optional
- (void) attachPDF:(NSString *)pdf target:(id)target;
- (void) CloseServiceReport:(id)sender;

@end


@interface PDFCreator:UIViewController
<MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate>
{
    id <PDFCreatorDelegate> delegate;
    
    iServiceAppDelegate * appDelegate;
    
    iOSInterfaceObject * iOSObject;
    
    IBOutlet UIWebView * webView;
    IBOutlet UIActivityIndicatorView * activity;
    IBOutlet UIButton * sendMailButton;
    IBOutlet UIButton * backButton;
    
    NSString * woId;
    NSString * _wonumber, * _date, * _recordId;
    NSArray * _account;
    NSString * _contact, * _phone;
    NSString * _description, * _workPerformed;
    NSString * _totalCost;
    
    UIImage * _signature;
    
    NSArray * _parts, * _expenses;
    
    //krishna defect : 5813
    NSMutableArray *travelArray;
    
    NSMutableArray * _labor;
    
    NSString *saveFileName, *newFilePath;
    
    IBOutlet UILabel * statusDescription;
    
    BOOL createPDF;
    BOOL calledFromSummary;
    
    CGPoint currentPoint;
    
    CGContextRef pdfContext;
    CGRect pageRect;
    
    UIInterfaceOrientation prevInterfaceOrientation;
    
    BOOL downloadFinished;
    
    NSString * srReportTitle, * srAddressType;
    BOOL srShowContactPhone, srShowProblemDescription, srShowWorkPerformed, srShowParts, srShowLabor, srShowExpenses, srShowLinePrice, srShowDiscount;
    NSMutableArray * customFields;
    
    NSMutableDictionary * workOrderDetails;
    
    CGSize lastHeight;
    
    CGPoint phoneNewLine;
    
    NSMutableArray * reportEssentials;
    NSMutableDictionary * reportEssentialsDict;
    
    BOOL didRunOperation;
    
    BOOL didremovepdf;
    BOOL didremoveallPdf;
    
    BOOL shouldShowBillablePrice;
    BOOL shouldShowBillableQty;
}

@property (nonatomic, assign) id <PDFCreatorDelegate> delegate;

@property (nonatomic, retain) NSString * woId;
@property (nonatomic, retain) NSString * _wonumber, * _date, * _recordId;
@property (nonatomic, retain) NSArray * _account;
@property (nonatomic, retain) NSString * _contact, * _phone;
@property (nonatomic, retain) NSString * _description, * _workPerformed;
@property (nonatomic, retain) NSString * _totalCost;
@property (nonatomic, retain) NSArray * _parts, * _expenses;
@property (nonatomic, retain) NSMutableArray * _labor;
//krishna defect : 5813
@property (nonatomic, retain) NSMutableArray *travelArray;

@property (nonatomic, retain) UIImage * _signature;
@property (nonatomic,assign) BOOL shouldShowBillablePrice;
@property (nonatomic,assign) BOOL shouldShowBillableQty;

@property BOOL createPDF;
@property BOOL calledFromSummary;

@property UIInterfaceOrientation prevInterfaceOrientation;

@property (nonatomic, retain) NSMutableDictionary * workOrderDetails;

@property (nonatomic, retain) NSMutableArray * reportEssentials;

- (IBAction) Close;

- (void) mailServiceReport;

- (void) removeAllPDF:(NSString *)pdf;
- (void) didGetPDFList:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didRemoveAllPDF:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) attachPDF:(NSString *)pdf;
- (void) didAttachPDF:(ZKQueryResult *)result error:(NSError *)error context:(id)context;

- (IBAction) sendMail;

- (void) showServiceReportForId:(NSString *)woId fileName:(NSString *)saveFileName;
- (void) getServiceReport:(NSString *)filename;
- (void) didQueryAttachmentForServiceReport:(ZKQueryResult *)result error:(NSError *)error context:(id)context;

// PDF Creation API
- (void) CreatePDF;
- (void) CreatePDFFile:(NSString *)filename;

- (void) PDFPageBegin;
- (void) PDFPageEnd;

- (void) createMainPage;
- (NSString *) getValueFromDisplayValue:(NSString *)displayValue;
- (void) createCustomFields;
- (void) setBOOLImage:(BOOL)flag atXLocation:(CGFloat)location;

- (void) createPage;
// Set Header Image
- (void) setHeaderImage;
// Set Back Image
- (void) setServiceReportImage;
// Set Report Title
- (void) setReportTitle;
// Set Details Of Work Performed Image
- (void) setDetailsOfWorkPerformed;
// Set Parts Image
- (void) setPartsImage;

//krishna defect : 5813
- (void)setTravelImage;


// Set Labor Image
- (void) setLaborImage;
// Set Expenses Image
- (void) setExpenseImage;
// Set Signature Image
- (void) setSignatureImage;
- (void) setSignature;
// Set Total Cost
- (void) setTotalCost:(NSString *)totalCost;
// Set Header Text
- (void) setHeaderText:(NSString *)headerText;
// Go to newline
- (CGPoint) newLine:(float_t)height;
- (void) newPara:(float_t)height;
// Draw horizontal line
- (void) drawHorizontalLine;
// Write Text
- (void) writeText:(NSString *)_text;

- (void) setWorkOrder:(NSString *)wonumber;
- (void) setDate:(NSDate *)date;
- (void) setAccount:(NSArray *)account;
- (void) setContact:(NSString *)contact;
- (void) setPhone:(NSString *)phone;
- (void) setImageWithName:(NSString *)imageName;
- (void) setDescription:(NSString *)description;
- (void) setWorkPerformed:(NSString *)workPerformed;

// Write Parts
- (void) writePartsNo:(NSString *)sno part:(NSString *)part qty:(NSString *)qty unitprice:(NSString *)unitprice lineprice:(NSString *)lineprice;
// Write Parts with Discount
- (void) writePartsNo:(NSString *)sno part:(NSString *)part qty:(NSString *)qty unitprice:(NSString *)unitprice lineprice:(NSString *)lineprice discount:(NSString *)discount;
// Insert spaces
- (void) insertSpaces:(NSUInteger)numSpaces;

- (IBAction) Help;

- (IBAction) displayUser:(id)sender;

- (NSDictionary *) getObjectForKey:(NSString *)key;

//RADHA - ServiceReportLogo
- (NSString *) getLogoFromDatabase;

@end

#define CFONTNAME           "Verdana"
#define CBOLDFONTNAME       "Verdana-Bold"
#define FONTNAME            @CFONTNAME

#define DEBUG

#define xBuffer             50
#define yBuffer             10
#define newLineBuffer       8
#define kBoundaryBuffer     100
#define kTab                10
#define spaceBuffer         10


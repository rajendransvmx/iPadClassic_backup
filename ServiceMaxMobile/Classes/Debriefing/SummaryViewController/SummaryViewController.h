//
//  SummaryViewController.h
//  Debriefing
//
//  Created by Sanchay on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import "AppDelegate.h"
#import "LabourViewController.h"
#import "WorkPerformedCellView.h"
#import "PartsCellView.h"
#import "LabourCellView.h"
#import "ExpensesCellView.h"
//krishna defect 5813
#import "TravelcellView.h"

#import "SignatureViewController.h"
#import "Globals.h"

#import "PDFCreator.h"

@protocol SummaryViewControllerDelegate <NSObject>

@optional
- (void) CloseSummaryView;
- (void) attachPDF:(NSString *)pdf target:(id)target selector:(SEL)selector context:(id)context;

@end

@interface SummaryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PDFCreatorDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate>
{
    id <SummaryViewControllerDelegate> delegate;
    
    AppDelegate * appDelegate;
    
	IBOutlet UITableView *summarytable;
	NSMutableArray *Parts, *Expenses, * Labour;

    double totalCost;//#3014
	IBOutlet UILabel *LblTotalCost;
	IBOutlet UIImageView *signature;
	SignatureViewController *sign;
	NSData *signimagedata, * encryptedImage;
    
    UIInterfaceOrientation prevInterfaceOrientation;
    
    NSMutableDictionary * workOrderDetails;
    
    IBOutlet UITextView * workPerformedView;
    
    IBOutlet UILabel * titleLabel;
    NSString * workDescription;
    IBOutlet UILabel *totalAmount;
    
    NSMutableArray * reportEssentials;
    
    //Shrinivas
    NSString * recordId;
    NSString * objectApiName;
    
    BOOL     shouldShowBillablePrice;
    BOOL     shouldShowBillableQty;
}


@property (nonatomic, retain) NSMutableArray *travel; //Krishna defect : 5813

@property (nonatomic, assign) id <SummaryViewControllerDelegate> delegate;
@property (nonatomic, retain) NSData *signimagedata;
@property (nonatomic, retain) NSData *encryptedImage;
@property UIInterfaceOrientation prevInterfaceOrientation;
@property (nonatomic, retain) NSMutableDictionary * workOrderDetails;

@property (nonatomic, retain) NSMutableArray *Parts, *Expenses, *Labour;

@property (nonatomic, retain) NSString * workDescription;

@property (nonatomic, retain) NSMutableArray * reportEssentials;

//Shrinivas
@property (nonatomic, retain) NSString *recordId;
@property (nonatomic, retain) NSString *objectApiName;
@property(nonatomic,assign)   BOOL     shouldShowBillablePrice;
@property(nonatomic,assign)   BOOL     shouldShowBillableQty;

- (IBAction) Done;

- (void) PopulateData;

- (IBAction) ShowSignature;

- (void) SignatureDone;

- (IBAction) createPDF;

- (NSString *) getFormattedDate:(NSString *)date;

- (NSString *) getFormattedCost:(double)cost;//#3014

- (IBAction) Help;

- (void) setTotalCost;

- (IBAction) displayUser:(id)sender;

@end

#define LABOUR_NAME @"Name"
#define LABOUR_RATE @"Rate"
#define LABOUR_HOURS @"Hours"
#define LABOUR_DESCRIPTION @"Labour_Description"

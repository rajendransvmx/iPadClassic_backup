//
//  SummaryViewController.h
//  Debriefing
//
//  Created by Sanchay on 9/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import "iServiceAppDelegate.h"
#import "LabourViewController.h"
#import "WorkPerformedCellView.h"
#import "PartsCellView.h"
#import "LabourCellView.h"
#import "ExpensesCellView.h"
#import "SignatureViewController.h"
#import "Globals.h"

#import "PDFCreator.h"

@protocol SummaryViewControllerDelegate <NSObject>

@optional
- (void) CloseSummaryView;
- (void) attachPDF:(NSString *)pdf target:(id)target selector:(SEL)selector context:(id)context;

@end

@interface SummaryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PDFCreatorDelegate, UIPopoverControllerDelegate>
{
    id <SummaryViewControllerDelegate> delegate;
    
    iServiceAppDelegate * AppDelegate;
    
	IBOutlet UITableView *summarytable;
	NSMutableArray *Parts, *Expenses, * Labour;

	float totalCost;
	IBOutlet UILabel *LblTotalCost;
	IBOutlet UIImageView *signature;
	SignatureViewController *sign;
	NSData *signimagedata;
    
    UIInterfaceOrientation prevInterfaceOrientation;
    
    NSMutableDictionary * workOrderDetails;
    
    IBOutlet UITextView * workPerformedView;
    
    IBOutlet UILabel * titleLabel;
    NSString * workDescription;
    IBOutlet UILabel *totalAmount;
    
    NSMutableArray * reportEssentials;
}

@property (nonatomic, assign) id <SummaryViewControllerDelegate> delegate;
@property (nonatomic, retain) NSData *signimagedata;
@property UIInterfaceOrientation prevInterfaceOrientation;
@property (nonatomic, retain) NSMutableDictionary * workOrderDetails;

@property (nonatomic, retain) NSMutableArray *Parts, *Expenses, *Labour;

@property (nonatomic, retain) NSString * workDescription;

@property (nonatomic, retain) NSMutableArray * reportEssentials;

- (IBAction) Done;
- (void) PopulateData;
- (IBAction) ShowSignature;
- (void) SignatureDone;

- (IBAction) createPDF;
- (NSString *) getFormattedDate:(NSString *)date;

- (NSString *) getFormattedCost:(float)cost;

- (IBAction) Help;

- (void) setTotalCost;

- (IBAction) displayUser:(id)sender;

@end

#define LABOUR_NAME @"Name"
#define LABOUR_RATE @"Rate"
#define LABOUR_HOURS @"Hours"
#define LABOUR_DESCRIPTION @"Labour_Description"

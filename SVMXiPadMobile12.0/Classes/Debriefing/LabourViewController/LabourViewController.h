//
//  LabourViewController.h
//  Debriefing
//
//  Created by Sanchay on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "Globals.h"
#import "PopOverKeyboard.h"


@interface LabourViewController : UIViewController <UIPopoverControllerDelegate,UITextFieldDelegate, NumericKeyboardDelegate>
{
    iServiceAppDelegate *AppDelegate;
	IBOutlet UISlider *Calibration, *Cleanup, *Installation, *Repair, *Service;
	IBOutlet UILabel *LblCalibration, *LblCleanup, *LblInstallation, *LblRepair, *LblService;
	NSDictionary *LabourLabelDictionary, *LabourSliderDictionary, *LabourValuesDictionary;
	id parent;
	BOOL dataloaded;
	NSString *rate;
    
    BOOL willRecoverFromMemoryError;
	PopOverKeyboard *keyboard;


	IBOutlet UITextField * rateCalibration, * rateCleanup, * rateInstallation, * rateRepair, *rateService;
    
    BOOL calculateLaborPrice, settingsPresent, groupCostsPresent, laborPriceEditable;
    
    NSMutableArray * linePriceItems;
}

@property (nonatomic, retain) id parent;

@property BOOL willRecoverFromMemoryError;

- (IBAction) SliderValueChanged:(id)sender;
- (void) InitLaborData;
//- (NSString *) GetLaborRate;//  Unused Methods
- (IBAction) ShowDesc:(id)sender;

@end

#define CALIBRATION @"Calibration"
#define CLEANUP @"Cleanup"
#define INSTALLATION @"Installation"
#define REPAIR @"Repair"
#define SERVICE @"Service"

#define RATE_CALIBRATION @"Rate_Calibration"
#define RATE_CLEANUP @"Rate_Cleanup"
#define RATE_INSTALLATION @"Rate_Installation"
#define RATE_REPAIR @"Rate_Repair"
#define RATE_SERVICE @"Rate_Service"

#define QTY_CALIBRATION @"QTY_Calibration"
#define QTY_CLEANUP @"QTY_Cleanup"
#define QTY_INSTALLATION @"QTY_Installation"
#define QTY_REPAIR @"QTY_Repair"
#define QTY_SERVICE @"QTY_Service"

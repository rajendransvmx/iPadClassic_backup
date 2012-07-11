//
//  ExpenseViewController.h
//  Debriefing
//
//  Created by Sanchay on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "PopOverKeyboard.h"
#import "Globals.h"

@interface ExpenseViewController : UIViewController <UITextFieldDelegate, UIPopoverControllerDelegate>
{
    iServiceAppDelegate * AppDelegate;
	IBOutlet UITextField *Airfare, *Breakfast, *Dinner, *Lodging, *Parking, *Entertainment, *Lunch, *Gas, *Mileage, *Parts;
	PopOverKeyboard *keyboard;
	UIPopoverController *popover;
	
	NSDictionary * ExpenseDictionary;
	id parent;
	
	BOOL dataloaded;

	BOOL descriptionused;
    
    BOOL willRecoverFromMemoryError;
}

@property (nonatomic, retain) id parent;

@property BOOL willRecoverFromMemoryError;

- (void)keyboardWillShow:(id)sender;
- (void)SaveData;

- (void) InitExpenseData;

- (IBAction) ShowDesc:(id)sender;

@end

#define AIRFARE @"Airfare"
#define BREAKFAST @"Food - Breakfast"
#define DINNER @"Food - Dinner"
#define LODGING @"Lodging"
#define PARKING @"Parking"
#define ENTERTAINMENT @"Entertainment"
#define LUNCH @"Food - Lunch"
#define GAS @"Gas"
#define MILEAGE @"Mileage"
#define PARTS @"Parts"
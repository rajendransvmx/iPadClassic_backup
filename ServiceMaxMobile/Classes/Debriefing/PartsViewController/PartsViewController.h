//
//  PartsViewController.h
//  Debriefing
//
//  Created by Sanchay on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PartsTableViewCell.h"
#import "Globals.h"


@interface PartsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate>
{
    AppDelegate * appDelegate;
	IBOutlet UITableView *PartsTable;
	NSMutableArray *Parts;
	id parent;
	NSMutableArray *AllParts;
    
    BOOL dataloaded;
    
    NSMutableArray *partsConsumed;
    IBOutlet UIActivityIndicatorView *activity;
    
    BOOL willRecoverFromMemoryError;
    
    BOOL didSelectPartsSearch;
	
//pavaman 17th Jan 2011
	UIPopoverController *popover;

    BOOL userCanChangePartsPrice;
}

@property (nonatomic, retain) UITableView *PartsTable;
@property (nonatomic, retain) id parent;

@property BOOL willRecoverFromMemoryError;

@property BOOL didSelectPartsSearch;

- (void) initDebriefData;

- (void) getPriceBook;

- (void) didGetProductDetails:(ZKQueryResult *)result error:(NSError *)error context:(id)context;

@end
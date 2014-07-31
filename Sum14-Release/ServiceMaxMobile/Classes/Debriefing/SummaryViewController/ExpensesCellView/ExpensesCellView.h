//
//  ExpensesCellView.h
//  Debriefing
//
//  Created by Sanchay on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExpensesCellView : UIView
{
	IBOutlet UILabel *SrNo, *Expenses, *LinePrice;
}

@property (nonatomic, retain) UILabel *SrNo, *Expenses, *LinePrice;

@end

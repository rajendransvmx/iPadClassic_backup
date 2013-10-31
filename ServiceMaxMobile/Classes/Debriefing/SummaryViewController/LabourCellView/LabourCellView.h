//
//  LabourCellView.h
//  Debriefing
//
//  Created by Sanchay on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LabourCellView : UIView
{
	IBOutlet UILabel *SrNo, *Labour, *Rate, *Hours, *LinePrice;
}

@property (nonatomic, retain) UILabel *SrNo, *Labour, *Rate, *Hours, *LinePrice;

@end

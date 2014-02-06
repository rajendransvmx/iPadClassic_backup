//
//  PartsCellView.h
//  Debriefing
//
//  Created by Sanchay on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PartsCellView : UIView
{
	IBOutlet UILabel *SrNo, *Parts, *Qty, *UnitPrice, *LinePrice;
}

@property (nonatomic, retain) UILabel *SrNo, *Parts, *Qty, *UnitPrice, *LinePrice;

@end

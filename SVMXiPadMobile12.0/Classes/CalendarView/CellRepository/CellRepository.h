//
//  CellRepository.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 18/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CellRepository : UITableViewCell
{
    IBOutlet UIView * mView;
    IBOutlet UILabel * label;
    
    NSString * labelText;
}

@property (nonatomic, retain) IBOutlet UIView * mView;
@property (nonatomic, retain) IBOutlet UILabel * label;

//- (void) setLabelText:(NSString *)labelText;//  Unused methods
- (void) setColor:(UIColor *)color;

@end

//
//  BizRuleBaseTableViewCell.h
//  ServiceMaxiPad
//
//  Created by Sahana on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BizRuleCellDelegate;

@interface BizRuleBaseTableViewCell : UITableViewCell
@property (nonatomic, strong) NSString *titleDescription;
@property(nonatomic,assign) id <BizRuleCellDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, strong) NSString *subTitleDescription;
@property(nonatomic)BOOL checkBoxselected;
@end


@protocol BizRuleCellDelegate <NSObject>

-(void)cellTappedAtIndexPath:(NSIndexPath *)indexPath selectedValue:( BOOL)selectedvalue;

@end
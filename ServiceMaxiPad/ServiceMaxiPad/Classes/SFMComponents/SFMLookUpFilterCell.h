//
//  SFMLookUpFilterCell.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 04/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterDelegate <NSObject>

@optional
-(void)filterValueChanged:(BOOL)value forInexpath:(NSIndexPath *)indexPath;

@end

typedef NS_ENUM(NSInteger, CheckBoxStateType) {
    CheckBoxStateTypeNone = 1,
    CheckBoxStateTypeUnchecked,
    CheckBoxStateTypeChecked,
    CheckBoxStateTypeUncheckedDisabled,
    CheckBoxStateTypeCheckedDisabled
};

@interface SFMLookUpFilterCell : UITableViewCell

@property(nonatomic, assign)CheckBoxStateType checkBoxType;
@property(nonatomic, strong)NSIndexPath *indexPath;
@property(nonatomic, assign)BOOL checkBoxChecked;

@property(nonatomic, weak)id <FilterDelegate> delegate;

- (void)setFilterNameForLabel:(NSString *)name;
- (void)setCheckboxImageForType:(CheckBoxStateType)type;
- (void)setValueForCheckBox:(BOOL)value;
@end

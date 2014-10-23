//
//  SFMCollectionViewCell.h
//  CollectionSample
//
//  Created by Damodar on 29/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CellTypeNonEditableTextField,
    CellTypeEditableTextField,
    CellTypeDateField,
    CellTypePicklist,
    CellTypeTextArea,
    CellTypeCheckBox,
    CellTypeSwitch,
    CellTypeLookUp
} CellType;

@class SFMCollectionViewCell;
@protocol SFMCollectionViewCellDelegate <NSObject>

@optional
- (void)cellValue:(id)value didChangeForIndexpath:(NSIndexPath*)indexPath;
- (void)cellDidTapForIndexPath:(NSIndexPath*)indexpath andSender:(id)sender;
- (void)cellEditingBegan:(NSIndexPath*)indexpath andSender:(id)sender;
- (void)clearFieldAtIndexPath:(NSIndexPath*)indexPath andSender:(id)sender;

@end

@interface SFMCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) CellType type;
@property (nonatomic, assign) id<SFMCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UILabel *nameField;
@property(nonatomic,assign)BOOL shouldShowAsteric;


- (id)name;
- (void)setName:(id)name;

- (id)value;
- (void)setValue:(id)value;

- (void)setKeyBoardTypeOfTextField:(UIKeyboardType)keyboardType;

- (void)showSuperScript:(BOOL)shouldShow;


@property (nonatomic, strong) id valueField;
- (void)loadCell:(CellType)type;

@end

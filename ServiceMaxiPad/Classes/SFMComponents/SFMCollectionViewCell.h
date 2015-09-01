//
//  SFMCollectionViewCell.h
//  CollectionSample
//
//  Created by Damodar on 29/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditMenuLabel.h"
typedef enum {
    CellTypeNonEditableTextViewField,
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
- (void)launchBarcodeScannerForIndexPath:(NSIndexPath *)indexPath;
@end

@interface SFMCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) CellType type;
@property (nonatomic, assign) id<SFMCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) EditMenuLabel *nameField;
@property(nonatomic,assign)BOOL shouldShowAsteric;


- (id)name;
- (void)setName:(id)name;

- (id)value;
- (void)setValue:(id)value;

- (void)setTextFieldDataType:(NSString*)dataType;

- (void)showSuperScript:(BOOL)shouldShow;

-(void)setPrecision:(double)precision scale:(double)scale;

- (void)setFieldNameForeText:(NSString *)fieldName;


@property (nonatomic, strong) id valueField;
- (void)loadCell:(CellType)type;

@end

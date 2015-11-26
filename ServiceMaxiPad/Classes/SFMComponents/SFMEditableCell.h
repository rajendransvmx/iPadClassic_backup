//
//  SFMEditableCell.h
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMCollectionViewCell.h"
#import "TextField.h"

@interface SFMEditableCell : SFMCollectionViewCell <TextFieldDelegate>
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, assign)  NSInteger precision;
@property (nonatomic, assign)  NSInteger scale;
@property (nonatomic, assign)  NSInteger lenght;
@end

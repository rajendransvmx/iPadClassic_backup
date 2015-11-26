//
//  SFMTextAreaCell.h
//  CollectionSample
//
//  Created by Damodar on 01/10/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMCollectionViewCell.h"

@interface SFMTextAreaCell : SFMCollectionViewCell <UITextViewDelegate>
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, assign)  NSInteger lenght;

@end

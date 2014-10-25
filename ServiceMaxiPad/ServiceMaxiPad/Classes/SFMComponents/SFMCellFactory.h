//
//  SFMCellFactory.h
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMCollectionViewCell.h"
#import "DatabaseConstant.h"

extern NSString * const noneditReuseIdentifier;
extern NSString * const editableReuseIdentifier;
extern NSString * const dateReuseIdentifier;
extern NSString * const picklistReuseIdentifier;
extern NSString * const lookupReuseIdentifier;
extern NSString * const boolReuseIdentifier;
extern NSString * const textAreaReuseIdentifier;
extern NSString * const nonEditBoolReuseIdentifier;

@interface SFMCellFactory : NSObject

+ (NSString*)getResuseIdentifierForType:(NSString*)cellType;
+ (void)registerCellsFor:(UICollectionView*)collectionView;

@end

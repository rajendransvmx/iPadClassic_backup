//
//  SFMCellFactory.m
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMCellFactory.h"
#import "SFMCollectionViewCell.h"
#import "SFMNonEditableCell.h"
#import "SFMEditableCell.h"
#import "SFMDateCell.h"
#import "SFMPicklistCell.h"
#import "SFMLookUpCell.h"
#import "SFMCheckBoxCell.h"
#import "SFMTextAreaCell.h"
#import "SFMReadOnlyCheckBoxCell.h"
#import "SFMNonEditableTextViewCell.h"

NSString * const noneditReuseIdentifier = @"noneditablecell";
NSString * const editableReuseIdentifier = @"editableell";
NSString * const dateReuseIdentifier = @"datecell";
NSString * const picklistReuseIdentifier = @"picklistcell";
NSString * const lookupReuseIdentifier = @"lookupcell";
NSString * const boolReuseIdentifier = @"boolcell";
NSString * const textAreaReuseIdentifier = @"textareacell";
NSString * const nonEditBoolReuseIdentifier = @"noneditboolcell";

NSString * const noneditTextViewReuseIdentifier = @"nonedittextViewcell";

@implementation SFMCellFactory

+ (NSString*)getResuseIdentifierForType:(NSString*)cellType
{
    NSString *identifier = @"";
    if([cellType isEqualToString:kSfDTCurrency]
       || [cellType isEqualToString:kSfDTDouble]
       || [cellType isEqualToString:kSfDTPercent]
       || [cellType isEqualToString:kSfDTInteger]
       || [cellType isEqualToString:kSfDTString]
       || [cellType isEqualToString:kSfDTEmail]
       
       )
    {
        identifier = editableReuseIdentifier;
    }
    else if([cellType isEqualToString:kSfDTDate] || [cellType isEqualToString:kSfDTDateTime])
    {
        identifier = dateReuseIdentifier;
    }
    else if([cellType isEqualToString:kSfDTReference])
    {
        identifier = lookupReuseIdentifier;
    }
    else if([cellType isEqualToString:kSfDTPicklist] || [cellType isEqualToString:kSfDTMultiPicklist])
    {
        identifier = picklistReuseIdentifier;
    }
    else if([cellType isEqualToString:kSfDTTextArea])
    {
        identifier = textAreaReuseIdentifier;
    }
    else if([cellType isEqualToString:kSfDTBoolean])
    {
        identifier = boolReuseIdentifier;
    }
    else {
        
        identifier = editableReuseIdentifier;
    }
    
    return identifier;
}

+ (NSString*)getResuseIdentifierForNonEditableTextView
{
    return  noneditTextViewReuseIdentifier;
}

+ (void)registerCellsFor:(UICollectionView*)collectionView
{
    // Register cell classes
    [collectionView registerClass:[SFMNonEditableCell class] forCellWithReuseIdentifier:noneditReuseIdentifier];
    [collectionView registerClass:[SFMEditableCell class] forCellWithReuseIdentifier:editableReuseIdentifier];
    [collectionView registerClass:[SFMDateCell class] forCellWithReuseIdentifier:dateReuseIdentifier];
    [collectionView registerClass:[SFMPicklistCell class] forCellWithReuseIdentifier:picklistReuseIdentifier];
    [collectionView registerClass:[SFMLookUpCell class] forCellWithReuseIdentifier:lookupReuseIdentifier];
    [collectionView registerClass:[SFMCheckBoxCell class] forCellWithReuseIdentifier:boolReuseIdentifier];
    [collectionView registerClass:[SFMTextAreaCell class] forCellWithReuseIdentifier:textAreaReuseIdentifier];
    [collectionView registerClass:[SFMReadOnlyCheckBoxCell class] forCellWithReuseIdentifier:nonEditBoolReuseIdentifier];
    [collectionView registerClass:[SFMNonEditableTextViewCell class] forCellWithReuseIdentifier:noneditTextViewReuseIdentifier];
    
}

@end

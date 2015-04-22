//
//  SFMPageReferenceFieldCollectionViewCell.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageFieldCollectionViewCell.h"
typedef enum ContactSubviewType : NSInteger
{
    ContactSubviewTypeNone = 0,
    ContactSubviewTypeMail = 1,
    ContactSubviewTypeMessage = 2,
    ContactSubviewTypeBoth = 3,
}
ContactSubviewType;

@protocol SFMPageReferenceFieldDedegate <NSObject>

- (void)showSFMPageViewForRerenceField:(NSInteger)index;
- (void)openContactMeaageOrMail:(id)sender fieldName:(NSString *)fieldName;

@end

@interface SFMPageReferenceFieldCollectionViewCell : SFMPageFieldCollectionViewCell

@property(nonatomic, assign) ContactSubviewType contactFieldSubViewType;
@property(nonatomic, assign) NSInteger index;

@property(nonatomic, assign) id<SFMPageReferenceFieldDedegate> delegate;

@property(nonatomic, strong) UIButton *chatButton;
@property(nonatomic, strong) UIButton *mailButton;

- (void)isRefernceRecordExist:(BOOL)isRefernceRecordExist;
- (void)configureCellForContext:(ContactSubviewType)context;
@end

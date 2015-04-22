//
//  SFMHeaderLayout.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMHeaderLayout.h"
#import "SFPageButton.h"
#import "StringUtil.h"

@implementation SFMHeaderLayout

- (id)initWithDictionaty:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
    
        _enableAccountHistory = [[dictionary objectForKey:kPageHeaderShowAccountHistory] boolValue];
        _enableProductHistory = [[dictionary objectForKey:kPageHeaderShowProductHistory] boolValue];
        _enableAttachment = [[dictionary objectForKey:kPageHeaderEnableAttachments] boolValue];
        _enableAllSection = [[dictionary objectForKey:kPageDetailAllowNewLines] boolValue];
        _enableTroubleShooting = [[dictionary objectForKey:kPageEnableTroubleShooting] boolValue];
        _pageLayoutId = [dictionary objectForKey:kPageDetailPageLayoutId];
        _hdrLayoutId = [dictionary objectForKey:kSVMXHdrLayoutId];
        _name = [dictionary objectForKey:kPageHeaderName];
        _objectName = [dictionary objectForKey:kPageHeaderObjectName];
        _hideQuickSave = [[dictionary objectForKey:kPageShowHideQuickSave] boolValue];
        _hideSave = [[dictionary objectForKey:kPageShowHideSave] boolValue];
        
        _showAllSectionsByDefault = [[dictionary objectForKey:kPageHeaderShowAllSectionsByDefault] boolValue];
        
        
        NSMutableArray * sections = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSArray * headerSections = [dictionary objectForKey:kPageHeaderSections];
        
        for (NSDictionary * eachSection in headerSections) {
            if (eachSection != nil) {
                SFMHeaderSection * headerSection = [[SFMHeaderSection alloc] initWithDictionary:eachSection];
                [sections addObject:headerSection];
            }
        }
        _sections = sections;
    }
    
    NSMutableArray *allButtons = [[NSMutableArray alloc] init];
    NSArray *buttons =  [dictionary objectForKey:kPageHeaderButtons];
    for (int counter = 0; counter < [buttons count]; counter++) {
        
        SFPageButton *pageButton = [[SFPageButton alloc] init];
        NSDictionary *buttonDictionary = [buttons objectAtIndex:counter];
        pageButton.title = [buttonDictionary objectForKey:kPageHeaderBtnTitle];
        NSString *enabled = [[buttonDictionary objectForKey:kPageHeaderBtnEnable] stringValue];
        if ([StringUtil isItTrue:enabled]) {
            pageButton.enabled = YES;
        }
        
        NSArray *pageHeaderBtnEvents =  [buttonDictionary objectForKey:kPageHeaderBtnEvents];
        
        if ([pageHeaderBtnEvents count] > 0) {
            
            NSDictionary *callBackInfo = [pageHeaderBtnEvents objectAtIndex:0];
            NSString *callBkType = [callBackInfo objectForKey:kPageHeaderBtnEventCall];
            if (![StringUtil isStringEmpty:callBkType]) {
                pageButton.eventCallBackType = callBkType;
            }
            
            NSString *target = [callBackInfo objectForKey:kPageHeaderBtnEventTarget];
            if (![StringUtil isStringEmpty:target]) {
                pageButton.targetCall = target;
            }
            
            NSString *eventType = [callBackInfo objectForKey:kPageHeaderBtnEventType];
            if (![StringUtil isStringEmpty:eventType]) {
                pageButton.eventType = eventType;
            }
        }
        
        [allButtons addObject:pageButton];
        
    }
    self.buttons = allButtons;
    return self;
    
}

- (NSArray *)getAllHeaderLayoutFields
{
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
    for(SFMHeaderSection * eachSection in self.sections)
    {
        [fieldsArray addObjectsFromArray:eachSection.sectionFields];
    }
    return fieldsArray;
}

- (BOOL)isAccountyHistoryExists;
{
    return self.enableAccountHistory;
}

- (BOOL)isProductHistoryExists
{
    return self.enableProductHistory;
}

@end

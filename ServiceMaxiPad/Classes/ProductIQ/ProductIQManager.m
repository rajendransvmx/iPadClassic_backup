//
//  ProductIQManager.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 02/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductIQManager.h"
#import "MobileDeviceSettingService.h"
#import "StringUtil.h"
#import "SFWizardModel.h"
#import "WizardComponentModel.h"

@implementation ProductIQManager

/*
 Method Name:isProductIQEnabled
 Description: This method will check two conditions to enable ProductIQ wizard.
 They are:
 
 1. setting should be enabled.
 2. SFM Page should have IB or Location as fields.
 
 */
+ (BOOL)isProductIQEnabledForSFMPage:(SFMPageViewModel*)sfmPageView {
    BOOL productIQEnabled = NO;
    
    if ([[self class] isProductIQSettingEnable]) {
        if ([[self class] isProductIQRelatedFieldsAvailableOnSFMPageView:sfmPageView]) {
            productIQEnabled = YES;
        }
    }
    return productIQEnabled;
}

+ (BOOL)isProductIQSettingEnable {
    BOOL settingEnabled = NO;
    MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
    MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"PRODIQ002_SET001"];
    settingEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
    
    return settingEnabled;
}
+ (BOOL)isProductIQRelatedFieldsAvailableOnSFMPageView:(SFMPageViewModel*)sfmPageView {
    BOOL productIQFieldsAvailable = NO;
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [fieldsArray addObject:kWorkOrderSite]; // Location
    [fieldsArray addObject:kInstalledProductTableName]; //IB
    
    NSArray *headerSections = sfmPageView.sfmPage.process.pageLayout.headerLayout.sections;
    
    for (SFMHeaderSection *headerSection in headerSections) {
        for (SFMPageField *pageField in headerSection.sectionFields) {
            if ([fieldsArray containsObject:pageField.relatedObjectName]) {
                productIQFieldsAvailable = YES;
                break;
            }
        }
        if (productIQFieldsAvailable) {
            break;
        }
    }
    
    if (productIQFieldsAvailable == NO) {
        NSArray *detailSections = sfmPageView.sfmPage.process.pageLayout.detailLayouts;
        for (SFMDetailLayout *detailSection in detailSections) {
            for (SFMPageField *pageField in detailSection.detailSectionFields) {
                if ([fieldsArray containsObject:pageField.relatedObjectName]) {
                    productIQFieldsAvailable = YES;
                    break;
                }
            }
            if (productIQFieldsAvailable) {
                break;
            }
        }
    }
    return productIQFieldsAvailable;
}

/*
 Method addProductIQWizardForAllWizardArray
 Description:
 1. Get the all the process Ids(SFM,OUTPUT_DOCUMENT) from allWizardArray for each compoent.
 2. Compare the process Id. If matched then diasable the IB/Location creat/edit processes.
 3. Disable create/edit processes only for two objects i.e IB or Location as of now.
 4. Add ProductIQ wizard for ProductIQ.
 */

+ (NSMutableArray*)addProductIQWizardForAllWizardArray:(NSMutableArray*)allWizards withWizardComponetService:(SFMWizardComponentService*)wizardComponentService{
    
    @autoreleasepool {
        NSMutableArray *sfmProcessIds = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *outputDocProcessIds = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (SFWizardModel *wizardModel in allWizards) {
            for (WizardComponentModel *wizardComponentModel in wizardModel.wizardComponents) {
                
                if ([wizardComponentModel.actionType isEqualToString:@"SFM"]) {
                    [sfmProcessIds addObject:[NSString stringWithFormat:@"'%@'",wizardComponentModel.processId]];
                } else if ([wizardComponentModel.actionType isEqualToString:@"OUTPUT_DOCUMENT"]) {
                    [outputDocProcessIds addObject:[NSString stringWithFormat:@"'%@'",wizardComponentModel.processId]];
                }
            }
        }
        
        NSArray *sfmMatchedProcessIds = nil;
        NSArray *outputDocMatchedProcessIds = nil;
        if (sfmProcessIds.count > 0) {
            sfmMatchedProcessIds = [wizardComponentService getSFMProcessIdsWithSFMProcessArray:sfmProcessIds];
        }
        if (outputDocProcessIds.count > 0) {
            outputDocMatchedProcessIds = [wizardComponentService getOutputDocumentrocessIdsWithOutputDocumentArray:outputDocProcessIds];
        }
        
        NSMutableArray *matchedProcessIds = [[NSMutableArray alloc] initWithCapacity:0];
        
        if (sfmMatchedProcessIds.count > 0 ) {
            [matchedProcessIds addObjectsFromArray:sfmMatchedProcessIds];
            
        }
        if (outputDocMatchedProcessIds.count > 0) {
            [matchedProcessIds addObjectsFromArray:outputDocMatchedProcessIds];
        }
        
        //Now disable those process where processIds are going to match from matchProcessIds
        if (matchedProcessIds.count > 0) {
            for (NSString *processId in matchedProcessIds) {
                for (SFWizardModel *wizardModel in allWizards) {
                    for (WizardComponentModel *wizardComponentModel in wizardModel.wizardComponents) {
                        
                        if ([wizardComponentModel.actionType isEqualToString:@"SFM"] || [wizardComponentModel.actionType isEqualToString:@"OUTPUT_DOCUMENT"]) {
                            
                            if ([processId isEqualToString:wizardComponentModel.processId]) {
                                wizardComponentModel.isEntryCriteriaMatching = NO;
                            }
                        }
                    }
                }
            }
        }
        
        //Now add ProductIQ wizard to allWizard array.
        SFWizardModel *wizardModel = [[self class] getSFWizardForProductIQ];
        if (allWizards.count == 0) {
            allWizards = [[NSMutableArray alloc] initWithCapacity:0];
            [allWizards addObject:wizardModel];
        } else {
            [allWizards insertObject:wizardModel atIndex:0];
        }
        
        return allWizards;
    }
}

/*
 Method Name:getSFWizardForProductIQ
 Description: This method will create the wizard for ProductIQ, if productIQ is enabled.
 
 */
+ (SFWizardModel*)getSFWizardForProductIQ {
    SFWizardModel *wizardModel = [[SFWizardModel alloc]init];
    wizardModel.wizardName = @"ProductIQ";
    
    WizardComponentModel *wizardCompModel = [[WizardComponentModel alloc]init];
    wizardCompModel.actionType = @"ProductIQ";
    wizardCompModel.actionName = @"Enable ProductIQ";
    wizardCompModel.isEntryCriteriaMatching = YES;
    if (wizardModel.wizardComponents == nil)
    {
        wizardModel.wizardComponents = [[NSMutableArray alloc]init];
    }
    [wizardModel.wizardComponents addObject:wizardCompModel];
    return wizardModel;
}

@end
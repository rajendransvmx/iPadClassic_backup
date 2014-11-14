//
//  BizRuleManager.h
//  ServiceMaxiPhone
//
//  Created by Aparna on 10/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"
#import "JSExecuter.h"

@protocol BusinessRuleManagerDelegate <NSObject>

/**
 Informs the delegate that Business rule execution has been finished
 @param resultArray is the array instance with the business rule execution results
 */
- (void)businessRuleFinishedWithResults:(NSMutableArray *)resultArray;

/**
 Informs delegate that user has confirmed message or not.
 @param isConfirmed Boolean value which indicates user has confirmed or not.
 */
- (void)handleSaveOnWarningStatus:(BOOL)isConfirmed;

@end

/**
 A class which executes advanvnced data validation rules
 @author Aparna http://www.servicemax.com aparna.bhat@servicemax.com
 */

@interface BusinessRuleManager : NSObject<JSExecuterDelegate>

/**
 NSString instance to hold process id for which business rule needs to be executed
 */
@property(nonatomic, strong) NSString *processId;

/**
 SFPage Instance to hold a information of SFPage associated with processId
 */
@property(nonatomic, strong) SFMPage *sfmPage;

/**
 UIView Instance required to execute javascript.
 */
@property(nonatomic, strong) UIView *parentView;

/**
 The object that acts as the delegate of BusinessRuleManager. The delegate must adopt the BusinessRuleManagerDelegate protocol
 */
@property(nonatomic, assign)id<BusinessRuleManagerDelegate> delegate;

/**
 Dictionary to hold the record of user confirmed confirmed warnings
 */
//@property(nonatomic, strong) NSMutableDictionary *warningConfirmationDict;

/**
 This method is used to get the instance of BusinessRuleManager.
 @param processId for which business rule nedd to be executed.
 @param sfmPage SFPage instance
 @returns BusinessRuleManager object instance.
 */
- (id)initWithProcessId:(NSString *)processId sfmPage:(SFMPage *)sfmPage;

/**
 This method executes the business rule.
 @returns YES if business rule is executed successfully, otherwise NO
 */
- (BOOL)executeBusinessRules;

/**
 This method is used to get the number of errors
 @returns number of errors in the result executed by the BusinessRuleManager
 */
- (int)numberOfErrorsInResult;

/**
 This method  instantiate PriceCalculationManager
 @returns number of warnings in the result executed by the BusinessRuleManager.
 */
- (int)numberOfWarningsInResult;

/**
This methos is not used.
 */
- (BOOL)allWarningsAreConfirmed;

/**
 This method is to check whether user has confirmed for the warnings
 @param bizRuleResult Array of BusinessRuleResult
 @returns YES if all the confirmation messages are confirmed with YES or NO option.
 */
- (BOOL)allWarningsAreConfirmedForBusinessRuleResult:(NSArray *)bizRuleResult;


-(void)updateWarningDict;
@end

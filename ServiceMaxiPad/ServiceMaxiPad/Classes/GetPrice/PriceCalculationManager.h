//
//  PriceCalculationManager.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"
#import "JSExecuter.h"

/**
 This is a  Class which handles "get price" calculation on WO records.
 @author Shravya shridhar http://www.servicemax.com shravya.shridhar@servicemax.com
 */

/**
 This protocol needs to be implemented by the classes which needs result after price calculation.
 */
@protocol PriceCalculationManagerDelegate <NSObject>

- (void)priceCalculationFinishedSuccessFully:(SFMPage *)sfPage;
- (void)shouldShowAlertMessage:(NSString *)message;

@end


@interface PriceCalculationManager : NSObject <JSExecuterDelegate>

@property(nonatomic,assign) id <PriceCalculationManagerDelegate>managerDelegate;

/**
 This method  instantiate PriceCalculationManager
 @param codeSnippetId is name or Id from Code snippet table
 @param newParentView : on which webview will be added
 @returns object instance.
 */
- (id)initWithCodeSnippetId:(NSString *)codeSnippetId
              andParentView:(UIView *)newParentView;

/**
 This method  instantiate PriceCalculationManager
 @param targetRecord work order and work order lines
 @returns None
 */
- (void)beginPriceCalculationForTargetRecord:(SFMPage *)targetRecord;

@end




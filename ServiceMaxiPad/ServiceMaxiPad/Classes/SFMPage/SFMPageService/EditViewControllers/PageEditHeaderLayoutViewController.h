//
//  PageEditHeaderLayoutViewController.h
//  ServiceMaxMobile
//
//  Created by shravya on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageLayoutEditViewController.h"
@interface PageEditHeaderLayoutViewController : PageLayoutEditViewController

- (SFMPageField *)getPageFieldForField:(NSString *)fieldName;
- (SFMRecordFieldData *)getRecordDataForField:(NSString *)fieldName;

@end

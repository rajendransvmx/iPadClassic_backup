//
//  CustomActionXMLRequestHelper.h
//  ServiceMaxiPad
//
//  Created by Apple on 17/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActionXMLRequestHelper : UICollectionViewCell

-(NSString *)getXmlBody;
- (NSString *)getSFMCustomActionsParamsRequest;
@end

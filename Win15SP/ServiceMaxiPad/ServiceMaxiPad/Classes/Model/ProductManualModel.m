//
//  ProductManualModel.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualModel.h"

@implementation ProductManualModel

- (void)explainMe
{
    SXLogInfo(@"prod_manual_Id = %@,\n prod_manual_name = %@,\n ProductId = %@",self.prod_manual_Id,self.prod_manual_name,self.ProductId);
}

- (void)dealloc
{
    self.ProductId = nil;
    self.prod_manual_name = nil;
    self.prod_manual_Id = nil;
}



@end

//
//  OPDocFileUploader.h
//  ServiceMaxiPad
//
//  Created by Admin on 31/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OPDocFileUploader : NSObject

+(void)requestForUploadingOPDocFilewithTheCallerDelegate:(id)delegate;
+(void)requestForSubmittingHTMLAndSignatureDocumentwithTheCallerDelegate:(id)delegate;
+(void)requestForGeneratingPDFwithTheCallerDelegate:(id)delegate;

+ (void)requestTocheckIfOPDocFileIsUploadedBeforewithTheCallerDelegate:(id)delegate;

@end

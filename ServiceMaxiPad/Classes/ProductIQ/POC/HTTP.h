//
//  HTTP.h
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTP : NSObject {
    
    NSMutableData *responseData;
    
    NSString *callback;
    NSString *requestId;
    NSString *type;
    NSString *methodName;
    NSString *jsCallback;
    NSString *totalPages;
    NSString *currentPage;
    NSMutableString *paramStr;
}
@property(nonatomic,strong)NSMutableString *tempStr;

-(void)callServer:(NSString *)params;

@end

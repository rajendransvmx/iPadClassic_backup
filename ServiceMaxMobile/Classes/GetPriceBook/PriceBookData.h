//
//  GetPriceBookUtil.h
//  iService
//
//  Created by Shravya shridhar on 2/26/13.
//
//

#import <Foundation/Foundation.h>

@interface PriceBookData : NSObject {
    
    NSDictionary *targetObject;
    NSArray      *priceBookComponents;
    NSString     *jsonRepresentation;
}

@property (nonatomic,retain) NSDictionary *targetObject;
@property (nonatomic,retain) NSArray      *priceBookComponents;
@property(nonatomic,retain)  NSString     *jsonRepresentation;

- (NSString *)getJSONRepresentationForJS;
- (id)initWithSfmPage:(NSDictionary *)sfmPage;

@end

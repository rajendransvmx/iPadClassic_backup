//
//  Item.h
//  iServiceHomeScreen
//
//  Created by Aparna on 09/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *detailedDescription;
@property(nonatomic, retain) UIImage *icon;


- (id)initWithTitle:(NSString *)title
        description:(NSString *)description
               icon:(UIImage *)icon;
@end

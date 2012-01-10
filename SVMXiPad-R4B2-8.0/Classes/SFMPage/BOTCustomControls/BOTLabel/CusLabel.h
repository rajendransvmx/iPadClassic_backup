//
//  CusLabel.h
//  CustomClassesipad
//
//  Created by Developer on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CusLabel : UILabel 
{
    BOOL shouldResizeAutomatically;
}

@property BOOL shouldResizeAutomatically;

-(NSString *) getLabel;
@end

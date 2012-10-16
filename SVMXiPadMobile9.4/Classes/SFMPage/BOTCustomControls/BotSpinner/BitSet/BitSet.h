//
//  BitSet.h
//  DependentPicklist
//
//  Created by Siva Manne on 28/11/11.
//  Copyright (c) 2011 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitSet : NSObject
{
        //Byte data[1024];
    NSString *nsstr;
    NSData   *nsdata;
}
-(id)initWithString:(NSString *) inputData;
-(Boolean) testBit:(int) n;
-(int) size;
@end

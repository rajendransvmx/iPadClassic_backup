//
//  BitSet.m
//  DependentPicklist
//
//  Created by Siva Manne on 28/11/11.
//  Copyright (c) 2011 ServiceMax. All rights reserved.
//

#import "BitSet.h"
#import "Base64.h"
extern void SVMXLog(NSString *format, ...);

@implementation BitSet
-(id)initWithString:(NSString *) inputData
{
    if([super init])
       {
           nsstr = inputData;
           //nsdata = [nsstr dataUsingEncoding:NSUTF8StringEncoding];
           nsdata = [Base64 decode:inputData];
           //SMLog(@"%@",nsdata);
       }
       return self;
}
    
-(Boolean) testBit:(int) n
{
    int index = n >> 3;
    
    Byte * data = (Byte *)[nsdata bytes];//[nsstr characterAtIndex:index];
    //SMLog(@"data =========%@",nsdata);
    return (data[index] & (0x80 >> n % 8)) != 0;
}

-(int) size
{
    int length;
    length = [nsstr length] * 8;
    //length = [nsdata length] ;
    //SMLog(@"Length = %d",length);
    return length;
}
@end

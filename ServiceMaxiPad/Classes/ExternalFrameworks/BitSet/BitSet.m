//
//  BitSet.m
//  DependentPicklist
//
//  Created by Siva Manne on 28/11/11.
//  Copyright (c) 2011 ServiceMax. All rights reserved.
//

#import "BitSet.h"
#import "Base64.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation BitSet

- (id)initWithString:(NSString *)inputData
{
    self =  [super init];
    
    if (self)
    {
        nsstr = inputData;
        //nsdata = [nsstr dataUsingEncoding:NSUTF8StringEncoding];
        nsdata = [Base64 decode:inputData];
        //SMLog(kLogLevelVerbose,@"%@",nsdata);
    }
    return self;
}
    
- (BOOL)testBit:(int) n
{
    int index = n >> 3;
    //fix for 8978
    
    
    // 27079
    
    /*
    
    NSUInteger len = [nsdata length];
    Byte *data = (Byte*)calloc(len, sizeof(char));
    memcpy(data, [nsdata bytes], len);
     
     */
    
    
    uint8_t *data = (uint8_t *)[nsdata bytes];
    
 // Byte * data = (Byte *)[nsdata bytes];//[nsstr characterAtIndex:index];
    //SMLog(kLogLevelVerbose,@"data =========%@",nsdata);

     // int value = (data[index] & (0x80 >> n % 8));
    
    Boolean flag = (data[index] & (0x80 >> n % 8)) != 0;
    
        //    NSLog(@"%d",n >> 3);
        //    NSLog(@"%d",data[n >> 3]);
        //    NSLog(@"%d",(0x80 >> n % 8));
        //    NSLog(flag ? @"Yes" : @"No");
        //    NSLog(@" %d",(data[n >> 3] & (0x80 >> n % 8)));
        //    NSLog(@"%d",n);
        //    NSLog(@"%@",[nsdata description]);
    
    
    
//    free(data);
    
    return flag;
}

- (int)size
{
    int length = 0;
    length = (int)([nsstr length] * 8);
    //length = [nsdata length] ;
    //SMLog(kLogLevelVerbose,@"Length = %d",length);
    return length;
}

@end

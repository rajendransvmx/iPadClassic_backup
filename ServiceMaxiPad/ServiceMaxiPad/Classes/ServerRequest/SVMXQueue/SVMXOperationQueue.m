//
//  SVMXOperationQueue.m
//  OperationQueue
//
//  Created by Shravya shridhar on 1/21/14.
//  Copyright (c) 2014 Shravya shridhar. All rights reserved.
//

#import "SVMXOperationQueue.h"


static SVMXOperationQueue *sharedInstanceSVMXOperationQue = nil;

@implementation SVMXOperationQueue

@synthesize mainopQueue;


- (id)init {
    self = [super init];
    if (self != nil) {
       self.mainopQueue = [[NSOperationQueue alloc] init];;
    }
    return self;
}

+ (SVMXOperationQueue *)sharedSVMXOperationQueObject {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      
                      if (sharedInstanceSVMXOperationQue == nil) {
                          sharedInstanceSVMXOperationQue = [[SVMXOperationQueue alloc] init];
                      }
                  }
                  );
    
    return sharedInstanceSVMXOperationQue;
}

#pragma mark - 
- (void)addOperationToQue:(NSOperation *)operation {
    
    @synchronized([self class]) {
        if (operation != nil) {
            [self.mainopQueue addOperation:operation];
           
        }
    }
}


- (void)cancelAllOperations {
     @synchronized([self class]) {
         [self.mainopQueue cancelAllOperations];
       
     }
}
@end

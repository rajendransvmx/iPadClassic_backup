//
//  SVMXOperationQueue.m
//  OperationQueue
//
//  Created by Shravya shridhar on 1/21/14.
//  Copyright (c) 2014 Shravya shridhar. All rights reserved.
//

#import "SVMXOperationQueue.h"
#import "SVMXServerRequest.h"

static SVMXOperationQueue *sharedInstanceSVMXOperationQue = nil;

@implementation SVMXOperationQueue


- (id)init {
    self = [super init];
    if (self != nil) {
        self.mainOpQueue = [[NSOperationQueue alloc] init];
        self.locationOpQueue = [[NSOperationQueue alloc] init];
        self.logsOpQueue     = [[NSOperationQueue alloc] init];
        self.getPriceOpQueue = [[NSOperationQueue alloc] init];
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
            CategoryType categoryType = ((SVMXServerRequest*)operation).categoryType;
            if (categoryType == CategoryTypeLocationPing)
            {
                [self.locationOpQueue addOperation:operation];
            }
            else if (categoryType == CategoryTypeJobLog)
            {
                [self.logsOpQueue addOperation:operation];
            }
            else if (categoryType == CategoryTypeGetPriceData)
            {
                [self.getPriceOpQueue addOperation:operation];
            }
            else
            {
                [self.mainOpQueue addOperation:operation];
            }
        }
    }
}


- (void)cancelAllOperations {
     @synchronized([self class]) {
         [self.mainOpQueue cancelAllOperations];
       
     }
}
@end

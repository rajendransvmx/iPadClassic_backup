//
//  SVMXOperationQueue.h
//  OperationQueue
//
//  Created by Shravya shridhar on 1/21/14.
//  Copyright (c) 2014 Shravya shridhar. All rights reserved.
//

/* This class will hold request objects and acts as a asynchronous queue */

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

@interface SVMXOperationQueue : NSObject {
    
    NSOperationQueue        *mainopQueue;
   
}

@property(nonatomic,strong)NSOperationQueue     *mainOpQueue;
@property(nonatomic,strong)NSOperationQueue     *logsOpQueue;
@property(nonatomic,strong)NSOperationQueue     *locationOpQueue;
@property(nonatomic,strong)NSOperationQueue     *getPriceOpQueue;


+ (SVMXOperationQueue *)sharedSVMXOperationQueObject;

- (void)addOperationToQue:(NSOperation *)operation;

- (void)cancelAllOperationsForCategoryType:(CategoryType)categoryType;

@end

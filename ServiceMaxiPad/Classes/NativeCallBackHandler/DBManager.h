//
//  DBManager.h
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ModifiedRecordModel.h"

@interface DBManager : NSObject
{
    NSString *databasePath;
}
@property (nonatomic, assign) BOOL isfieldMergeEnabled;

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(NSMutableArray *)executeQuery:(NSString *)query;

@end
//
//  DBManager.h
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(NSMutableArray *)executeQuery:(NSString *)query;

@end
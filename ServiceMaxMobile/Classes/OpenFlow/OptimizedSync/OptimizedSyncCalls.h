//
//  OptimizedSyncCalls.h
//  iService
//
//  Created by Radha S on 7/17/13.
//
//

#import <Foundation/Foundation.h>
#import "SBJsonWriter.h"
#import "SBJsonParser.h"

@class WSInterface;
@class AppDelegate;

@interface OptimizedSyncCalls : NSObject
{
	AppDelegate * appdelegate;
	BOOL callBackValue;
	NSString * callBackContextKey;
	NSString * callBackContextValue;
	NSString * syncRequestId;
	NSString * lastSyncTime;
	NSString * putUpdateSyncTime;
	NSMutableArray * purgingEventIdArray;
	NSArray * callBackValuemap;
}

@property (nonatomic, assign) BOOL callBackValue;

@property (nonatomic, retain) NSString * lastSyncTime;
@property (nonatomic, retain) NSString * putUpdateSyncTime;
@property (nonatomic, retain) NSMutableArray * purgingEventIdArray;
@property (nonatomic, retain) NSArray * callBackValuemap;

//Methods
-(void)GetOptimizedDownloadCriteriaRecordsFor:(NSString *)event_name requestId:(NSString *)requestId;
- (void) parseOptimizedDownloadCriteriaResponse:(NSString *)event_name response:(NSMutableArray *) array;
-(void) tx_fetch;
- (void) parseTXFetch:(NSMutableArray *) array;
- (void)deleteRecordIDsFromTrailerAndObjectTables:(NSDictionary *)safeToDeleteIDs;//9644
@end

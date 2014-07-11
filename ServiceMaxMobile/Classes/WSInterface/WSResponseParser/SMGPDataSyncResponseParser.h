//
//  SMGPDataSyncResponseParser.h
//  iService
//
//  Created by Siva Manne on 30/01/13.
//
//

#import "WSResponseParser.h"
@class INTF_WebServicesDefServiceSvc_SVMXMap;
@interface SMGPDataSyncResponseParser : WSResponseParser
@property (nonatomic, assign) NSMutableArray   *recordIDs;
@property (nonatomic, assign) NSString  *lastIndex;
@property (nonatomic, retain) NSString *lastId;  //D-00003729 - Price Calculation 2.0 (Radha)
- (BOOL) processFirstCallResponse:(INTF_WebServicesDefServiceSvc_SVMXMap * )svmxMapObject;
- (BOOL) processSecondCallResponse:(INTF_WebServicesDefServiceSvc_SVMXMap * )svmxMapObject;
- (BOOL) processThirdCallResponse:(INTF_WebServicesDefServiceSvc_SVMXMap * )svmxMapObject;
- (NSDictionary *) getSyncRecordHeapDictForSFID:(NSString *)sfId withSyncType:(NSString *)syncType;
@end

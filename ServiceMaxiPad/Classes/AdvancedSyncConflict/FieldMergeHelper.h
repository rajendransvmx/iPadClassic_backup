//
//  FieldMergeHelper.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 22/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldMergeHelper : NSObject

-(NSDictionary*)getDataDictionaryBeforeModificationFromTable:(NSString*)tableName withLocalId:(NSString*)localId fieldNames:(NSArray*)fieldNames;

- (NSString*)getJsonAfterComparingDictOne:(NSMutableDictionary*)dataBeforeModification withDataAfterModification:(NSMutableDictionary*)dataAfterModification andOldModificationDict:(NSMutableDictionary*)conflictDictionary;

//- (void)mergeExistingModifiedJsonWithNewlyCreatedJson:(NSMutableDictionary*)dataDictionaryBeforeModification an

@end

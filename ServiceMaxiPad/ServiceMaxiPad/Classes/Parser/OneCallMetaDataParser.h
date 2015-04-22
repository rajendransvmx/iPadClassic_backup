//
//  OneCallMetaDataParser.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "WebServiceParser.h"

@interface OneCallMetaDataParser : WebServiceParser
//TODO : NOT completed
@property(nonatomic, strong) NSMutableArray *sfProcess;
@property(nonatomic, strong) NSMutableArray *sfProcessTest;
@property(nonatomic, strong) NSMutableArray *sfExpression;
@property(nonatomic, strong) NSMutableArray *sfExpressionComponent;
@property(nonatomic, strong) NSMutableArray *sfNamedSearch;
@property(nonatomic, strong) NSMutableArray *sfNamedSearchComponent;
@property(nonatomic, strong) NSMutableArray *sfNamedSearchFilters;
@property(nonatomic, strong) NSMutableArray *sfObjectMapping;
@property(nonatomic, strong) NSMutableArray *sfObjectMappingComponent;


@end

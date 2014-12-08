//
//  StaticResourceService.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   StaticResourceService.h
 *  @class  StaticResourceService
 *
 *  @brief
 *
 *   This is a DAO service which interact with DB for static resource related info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "CommonServices.h"
#import "StaticResourceDAO.h"

@interface StaticResourceService : CommonServices <StaticResourceDAO>

@end

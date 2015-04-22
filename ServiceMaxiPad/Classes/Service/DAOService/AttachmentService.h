//
//  AttachmentService.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/21/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   AttachmentService.h
 *  @class  AttachmentService
 *
 *  @brief  This Database service class for Attachment table photos, videos and pdf etc
 *
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "CommonServices.h"
#import "AttachmentDAO.h"

@interface AttachmentService : CommonServices <AttachmentDAO>

@end

//
//  AttachmentLocalService.h
//  ServiceMaxMobile
//
//  Created by Anoop on 03/13/2015.
//  Copyright (c) 2015 Servicemax. All rights reserved.
//

/**
 *  @file   AttachmentLocalService.h
 *  @class  AttachmentLocalService
 *
 *  @brief  This Database service class for locally created Attachments Images and videos 
            which has localParentId and parentObjectName
 *
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2015 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "CommonServices.h"
#import "AttachmentLocalDAO.h"

@interface AttachmentLocalService : CommonServices <AttachmentLocalDAO>

@end

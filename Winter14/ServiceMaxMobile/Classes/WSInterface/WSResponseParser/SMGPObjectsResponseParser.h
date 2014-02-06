//
//  SMGPObjectsResponseParser.h
//  iService
//
//  Created by Siva Manne on 02/01/13.
//
//

#import "WSResponseParser.h"

@interface SMGPObjectsResponseParser : WSResponseParser
@property (nonatomic, retain) NSMutableArray *objectsWithPermission;
@end

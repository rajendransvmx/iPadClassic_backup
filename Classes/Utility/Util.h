//
//  Util.h
//  iService
//
//  Created by Vipindas on 2/5/13.
//
//

#import <Foundation/Foundation.h>
#import "DataBaseGlobals.h"

/*
 *  SFM Process Type
 *
 *  Discussion:
 *      Enumerates the different possible SFM Process
 *
 */

enum {
	SFMProcessTypeNone = 0,                     // Unknown process type
	SFMProcessTypeEdit,                         // Edit SFM records
	SFMProcessTypeStandAloneCreate,             // Stand Alone Create
    SFMProcessTypeSourceToTarget,               // Source to target create
    SFMProcessTypeSourceToTargetOnlyChildRows,  // Source to target only child row create
    SFMProcessTypeViewRecord,                   // View records
};
typedef NSInteger SFMProcessType;


/*
 *  SFM Action Type
 *
 *  Discussion:
 *      Enumerates the different possible SFM Actions
 *
 */

enum {
	SFActionTypeNone = 0,           // Unknown action
	SFActionTypeSFM,                // SFM action
	SFActionTypeWEBService,         // Any webservice call
    SFActionTypeSFMCustomActions,   // Any SFM custom actions
};
typedef NSInteger SFActionType;



@interface Util : NSObject {
    
}


/*
 *  isValidString:
 *
 *  Discussion:
 *    Returns YES if string is valid object otherwise NO.
 */

+ (BOOL)isValidString:(NSString *)string;

/*
 *  isValidEmailAddress:
 *
 *  Discussion:
 *    Returns YES if emailAddress is valid otherwise NO.
 */

+ (BOOL)isValidEmailAddress:(NSString *)emailAddress;



/*
 *  caseInsensitiveCompareString: withOtherString:
 *
 *  Discussion:
 *    Compare string case insensitively with otherString,
 *    returns YES if matching otherwise NO.
 */

+ (BOOL)caseInsensitiveCompareString:(NSString *)string
                     withOtherString:(NSString *)otherString;



/*
 *  getSFMProcessTypeByName:
 *
 *  Discussion:
 *    Returns SFM process type enum value based on the name of process. 
 */

+ (SFMProcessType)getSFMProcessTypeByName:(NSString *)name;

/*
 *  getSFActioTypeByName:
 *
 *  Discussion:
 *    Returns SFM action type enum value based on the name of action.
 */

+ (SFActionType)getSFActioTypeByName:(NSString *)name;


@end

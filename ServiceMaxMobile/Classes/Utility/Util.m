//
//  Util.m
//  iService
//
//  Created by Vipindas on 2/5/13.
//
//

#import "Util.h"

static NSString * const kEmailRegularExpression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";

@implementation Util

+ (BOOL)isValidString:(NSString *)string
{
    if (   (string == nil)
        || ([string isEqualToString:@""])
        || ([string length] == 0) )
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

//  Unused Methods
//+ (BOOL)isValidEmailAddress:(NSString *)emailAddress
//{
//    NSPredicate * emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kEmailRegularExpression];
//    return [emailPredicate evaluateWithObject:emailAddress];
//}

//  Unused Methods
//+ (BOOL)caseInsensitiveCompareString:(NSString *)string
//                     withOtherString:(NSString *)otherString
//{
//    if ( (![Util isValidString:string] ) || (! [Util isValidString:otherString] ) )
//    {
//        return NO;
//    }
//    else
//    {
//        return  (NSOrderedSame == [string caseInsensitiveCompare:otherString]);
//    }
//}

//  Unused Methods
//+ (SFMProcessType)getSFMProcessTypeByName:(NSString *)name
//{
//    if ( [Util caseInsensitiveCompareString:name withOtherString:@"STANDALONECREATE"])
//    {
//        return SFMProcessTypeStandAloneCreate;
//    }
//    else if ( [Util caseInsensitiveCompareString:name withOtherString:@"EDIT"])
//    {
//        return SFMProcessTypeEdit;
//    }
//    else if ( [Util caseInsensitiveCompareString:name withOtherString:@"SOURCETOTARGETONLYCHILDROWS"])
//    {
//        return SFMProcessTypeSourceToTargetOnlyChildRows;
//    }
//    else if ( [Util caseInsensitiveCompareString:name withOtherString:@"SOURCETOTARGET"])
//    {
//        return SFMProcessTypeSourceToTarget;
//    }
//    else if ( [Util caseInsensitiveCompareString:name withOtherString:@"VIEWRECORD"])
//    {
//        return SFMProcessTypeViewRecord;
//    }
//    else
//    {
//        return SFMProcessTypeNone;
//    }
//}

//  Unused Methods
//+ (SFActionType)getSFActioTypeByName:(NSString *)name
//{
//    if ( [Util caseInsensitiveCompareString:name withOtherString:SFM])
//    {
//        return SFActionTypeSFM;
//    }
//    else if ( [Util caseInsensitiveCompareString:name withOtherString:@"WEBSERVICE"])
//    {
//        return SFActionTypeWEBService;
//    }
//    else if ( [Util caseInsensitiveCompareString:name withOtherString:@"SFW_Custom_Actions"])
//    {
//        return SFActionTypeSFMCustomActions;
//    }
//    else
//    {
//        return SFActionTypeNone;
//    }
//}


@end

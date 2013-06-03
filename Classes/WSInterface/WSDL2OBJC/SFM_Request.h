#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
@class SFM_Request_SFM_Request;
@class SFM_Request_SFM_StringListMap;
@class SFM_Request_SFM_StringMap;
@interface SFM_Request_SFM_StringListMap : NSObject {
	
/* elements */
	NSString * fieldsToNull;
	NSString * key;
	NSMutableArray *valueList;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (SFM_Request_SFM_StringListMap *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * fieldsToNull;
@property (retain) NSString * key;
- (void)addValueList:(NSString *)toAdd;
@property (readonly) NSMutableArray * valueList;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface SFM_Request_SFM_StringMap : NSObject {
	
/* elements */
	NSString * fieldsToNull;
	NSString * key;
	NSString * value;
	NSString * value1;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (SFM_Request_SFM_StringMap *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * fieldsToNull;
@property (retain) NSString * key;
@property (retain) NSString * value;
@property (retain) NSString * value1;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface SFM_Request_SFM_Request : NSObject {
	
/* elements */
	NSString * fieldsToNull;
	NSString * groupId;
	NSString * profileId;
	NSMutableArray *stringListMap;
	NSMutableArray *stringMap;
	NSString * userId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (SFM_Request_SFM_Request *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * fieldsToNull;
@property (retain) NSString * groupId;
@property (retain) NSString * profileId;
- (void)addStringListMap:(SFM_Request_SFM_StringListMap *)toAdd;
@property (readonly) NSMutableArray * stringListMap;
- (void)addStringMap:(SFM_Request_SFM_StringMap *)toAdd;
@property (readonly) NSMutableArray * stringMap;
@property (retain) NSString * userId;
/* attributes */
- (NSDictionary *)attributes;
@end

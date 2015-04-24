//
//  CustomLibXml.m
//  iService
//
//  Created by Samman on 28/08/12.
//
//

#import "CustomLibXml.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

malloc_zone_t * zonePtr = NULL;

xmlFreeFunc freeFunc = NULL;
xmlMallocFunc mallocFunc = NULL;
xmlReallocFunc reallocFunc = NULL;
xmlStrdupFunc strdupFunc = NULL;

long zone_size = 0;

// Custom Initialize must be called only once, before any other xmllib methods are called
void custom_initialize()
{
    xmlMemSetup(custom_xmlFreeFunc, custom_xmlMallocFunc, custom_xmlReallocFunc, custom_xmlStrdupFunc);
}

// Custom create should be called everytime a malloc zone needs to be allocated
void custom_create()
{
    zone_size = 0;
    
    xmlMemGet(&freeFunc, &mallocFunc, &reallocFunc, &strdupFunc);
    
    custom_initialize();
   
    zonePtr = malloc_create_zone(0, 0);
}

// Custom destroy should be called everytime a malloc zone has to be destroyed
void custom_destroy()
{
    SMLog(kLogLevelVerbose,@"Zone Memory Size Before Destroy: %zd, %.2f", malloc_size(zonePtr), ((float)zone_size/1024/1024));

    malloc_destroy_zone(zonePtr);
    zonePtr = NULL;
    
    xmlMemSetup(freeFunc, mallocFunc, reallocFunc, strdupFunc);
    
    SMLog(kLogLevelVerbose,@"Zone Memory Size After Destroy: %zd", malloc_size(zonePtr));
}

void custom_xmlFreeFunc (void * mem)
{
    if (mem != NULL && zonePtr != NULL)
    {
         malloc_zone_free(zonePtr, mem);
    }
   
}

void * custom_xmlMallocFunc (size_t size)
{
    zone_size += size;
    return malloc_zone_malloc(zonePtr, size);
}

void * custom_xmlReallocFunc (void * mem, size_t size)
{
    zone_size = size;
    return malloc_zone_realloc(zonePtr, mem, size);
}

char * custom_xmlStrdupFunc (const char * s)
{
    char *d = malloc_zone_malloc(zonePtr, strlen (s) + 1);      // Space for length plus nul
    if (d == NULL)
        return NULL;                        // No memory
    strcpy (d,s);                           // Copy the characters
    zone_size += strlen(s)+1;
    return d;                               // Return the new string
}

@implementation CustomLibXml

@end

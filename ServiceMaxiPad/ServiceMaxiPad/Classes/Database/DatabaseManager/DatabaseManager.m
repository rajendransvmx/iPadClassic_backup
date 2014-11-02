//
//  DatabaseManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/26/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//
/**
 *  @file   DatabaseManager.m
 *  @class  DatabaseManager
 *
 *  @brief  This class will provide interface to talk to database file and database file encryption mechanism
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "DatabaseManager.h"
#import "FileManager.h"


NSString *const kMainDatabaseFileName          = @"sfm";
NSString *const kMainDatabaseFileExtension     = @"sqlite";
NSString *const kSecondaryDatabaseFileName     = @"temporary";
NSString *const kDatabaseAttachmentName        = @"tempsfm";

@interface DatabaseManager()
{
    
}

@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) DatabaseQueue *databaseQueueObject;

- (BOOL)createEditableDatabaseIfNeeded;

@end


@implementation DatabaseManager

#pragma mark Singleton Methods
+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    [self createEditableDatabaseIfNeeded];
    _databaseQueueObject = [DatabaseQueue databaseQueueWithPath:[self primaryDatabasePath]];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
#pragma mark - End
#pragma mark - Database Instance methods

/**
 * @name   createEditableDatabaseIfNeeded
 *
 * @author Vipindas Palli
 *
 * @brief  Validate database file existance, if not exist copy database template file from bundle.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return BOOL return Yes in case of success other wise No
 *
 */

- (BOOL)createEditableDatabaseIfNeeded
{
    NSError  *error = NULL;
    
    self.databasePath = [self primaryDatabasePath];
    
    BOOL fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:self.databasePath];
    
     NSLog(@"\n db exist in the path  - %@", self.databasePath);
    if (fileExistAtPath)
    {
        NSLog(@"\n db exist in the path");
    }
    else
    {
        NSLog(@"createEditableDatabaseIfNeeded called");
        /**
         *  We could not find database file at writeable data path.
         *  Copy template file from main bundle and save under application root directory.
         */
        
        NSString *databaseTemplateFilePath = [[NSBundle mainBundle] pathForResource:kMainDatabaseFileName
                                                                             ofType:kMainDatabaseFileExtension];
        if (databaseTemplateFilePath == nil)
        {
            NSLog(@"\n db not able to create error");
        }
        else
        {
            BOOL copiedTemplateDb = [[NSFileManager defaultManager] copyItemAtPath:databaseTemplateFilePath
                                                                          toPath:self.databasePath error:&error];
            if (! copiedTemplateDb)
            {
                NSLog(@"Failed to create writable database : %@", [error localizedDescription]);
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            }
            else
            {
                NSLog(@"DATABASE IS SUCCESSUFULLY CREATED");
            }
            
            fileExistAtPath = copiedTemplateDb;
        }
    }
    
    return fileExistAtPath;
}


- (DatabaseQueue *)databaseQueue
{
    return self.databaseQueueObject;
}

- (NSString *)primaryDatabasePath
{
    NSString *databasePath = [[FileManager getRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kMainDatabaseFileName, kMainDatabaseFileExtension]];
    
    return databasePath;
}

- (NSString *)secondaryDatabasePath
{
    NSString *databasePath = [[FileManager getRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kSecondaryDatabaseFileName, kMainDatabaseFileExtension]];
    
    return databasePath;
}

- (NSString *)databaseAttachmentName {
    return kDatabaseAttachmentName;
}
@end

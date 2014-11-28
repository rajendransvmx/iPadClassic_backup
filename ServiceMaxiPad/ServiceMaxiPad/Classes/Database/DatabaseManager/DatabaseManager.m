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
    
    NSLog(@"DBManager Initializing dbQ");
    
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
    
    BOOL hasValidDatabaseFile = NO;
    
    BOOL fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:self.databasePath];
    
    if (fileExistAtPath)
    {
        NSLog(@"\ndb file exist in the path  - %@", self.databasePath);
        hasValidDatabaseFile = YES;
    }
    else
    {
        NSLog(@"\ndb file not found, lets copy template to writable path ");
        /**
         *  Could not find database file at writeable data path.
         *  Copy template file from main bundle and save under application root directory.
         */
        
        NSString *databaseTemplateFilePath = [[NSBundle mainBundle] pathForResource:kMainDatabaseFileName
                                                                             ofType:kMainDatabaseFileExtension];
        if (databaseTemplateFilePath == nil)
        {
            NSLog(@"\nInvalid db template file path");
            hasValidDatabaseFile = NO;
        }
        else
        {
            BOOL copiedTemplateDb = [[NSFileManager defaultManager] copyItemAtPath:databaseTemplateFilePath
                                                                          toPath:self.databasePath
                                                                             error:&error];
            if (! copiedTemplateDb)
            {
                NSLog(@"\nFailed to create writable database : %@", [error localizedDescription]);
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
                hasValidDatabaseFile = NO;
            }
            else
            {
                NSLog(@"\nDatabase file restored");
                hasValidDatabaseFile = YES;
            }
        }
    }
    
    return hasValidDatabaseFile;
}


- (DatabaseQueue *)databaseQueue
{
    return self.databaseQueueObject;
}

- (NSString *)primaryDatabasePath
{
    NSString *databasePath = [[FileManager getRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kMainDatabaseFileName, kMainDatabaseFileExtension]];
    
    NSLog(@"DB Path : %@", databasePath);
    
    return databasePath;
}


- (NSString *)secondaryDatabasePath
{
    NSString *databasePath = [[FileManager getRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kSecondaryDatabaseFileName, kMainDatabaseFileExtension]];
    
    return databasePath;
}


/**
 * @name   resetDatabasePath
 *
 * @author Vipindas Palli
 *
 * @brief  Reset database file path
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return BOOL return Yes in case of success other wise No
 *
 */

- (void)resetDatabasePath
{
    self.databasePath = nil;
}


/**
 * @name   databaseAttachmentName
 *
 * @author Pushpak N
 *
 * @brief  Database Attachment Name
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return BOOL return Yes in case of success other wise No
 *
 */

- (NSString *)databaseAttachmentName
{
    return kDatabaseAttachmentName;
}
@end

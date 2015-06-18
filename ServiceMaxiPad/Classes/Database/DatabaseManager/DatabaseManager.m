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
#import "SMDatabase.h"


NSString *const kMainDatabaseFileName          = @"sfm";
NSString *const kMainDatabaseFileExtension     = @"sqlite";
NSString *const kSecondaryDatabaseFileName     = @"temporary";
NSString *const kDatabaseAttachmentName        = @"tempsfm";
NSString *const kDatabaseEncryptedDBName       = @"encrypted";



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


- (void)encryptAndExportDatabase
{
    // Encryption data base file path
    NSString *encryptedDataBasePath = [self encryptionDatabasePath];
    
    // Attach encrypted database Query
    const char* dbAttachQuery = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", encryptedDataBasePath, [self dbSecretKey]] UTF8String];
    
    sqlite3 *database;
    
    int dbEncrypted = -1; // Non Encrypted
    
    // Open primary database (unecrypted database)
    if (sqlite3_open([[self primaryDatabasePath] UTF8String], &database) == SQLITE_OK)
    {
        dbEncrypted = 1; // DB has opened
        
        // Attach empty encrypted database to unencrypted database
        int databaseAttached  = sqlite3_exec(database, dbAttachQuery, NULL, NULL, NULL);
        
        if (databaseAttached == SQLITE_OK)
        {
            dbEncrypted = 2; // Attached
            
            // export database
            int dbExported  = sqlite3_exec(database, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL); // Problem
            
            if (dbExported == SQLITE_OK)
            {
                NSLog(@"Successfully exported");
                dbEncrypted = 99; // Encrypted and exported
            }
            else
            {
                NSLog(@"DB export failed - '%s'.", sqlite3_errmsg(database));
                dbEncrypted = 3; // export failed
            }
            
            // Detach encrypted database
            int dbDettached = sqlite3_exec(database, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
            
            if (dbDettached == SQLITE_OK)
            {
                if(99 != dbEncrypted)
                {
                    dbEncrypted = 4; // DB dettached
                }
                NSLog(@"Successfully detached");
            }
            else
            {
                if(99 != dbEncrypted)
                {
                    dbEncrypted = 5; // DB dettached failed
                }
                NSLog(@"DB detachment failed -'%s'.", sqlite3_errmsg(database));
            }
        }
        else
        {
            dbEncrypted = 100; // Already Encrypted
            NSLog(@"DB Already encrypted or DB Encryption failed -'%s'.", sqlite3_errmsg(database));
        }
    }
    else
    {
        NSAssert1(NO, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_close(database);
    
    NSLog(@"--------- Encrypt database --------- %d", dbEncrypted);
    if (dbEncrypted == 99) // DB encrypted and exported; lets remove unecrypted (old) db file
    {
        NSLog(@"Encrypted file removing - DB encrypted");
        //
        [FileManager deleteFileAtPath:[self primaryDatabasePath]];
        [FileManager moveFileAtPath:encryptedDataBasePath toPath:[self primaryDatabasePath]];
       // [FileManager deleteFileAtPath:encryptedDataBasePath];
    }
    else if (dbEncrypted == 100)
    {
        NSLog(@" ==== DB Already encrypted or DB Encryption failed ====");//
        [FileManager deleteFileAtPath:encryptedDataBasePath];
        /*Rename the encrypted database and remove the unencrypted database*/
        //[FileManager deleteFileAtPath:[self primaryDatabasePath]];
        //[FileManager moveFileAtPath:encryptedDataBasePath toPath:[self primaryDatabasePath]];
    }
    else
    {
         NSLog(@" ==== DB not encrypted ====");
    }
    NSLog(@"--------- Encrypt database Completed---------");
}

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
        //NSLog(@"\ndb file exist in the path  - %@", self.databasePath);
        NSLog(@"db file exist");
        hasValidDatabaseFile = YES;
    }
    else
    {
        NSLog(@"db file not found, lets copy template to writable path ");
        /**
         *  Could not find database file at writeable data path.
         *  Copy template file from main bundle and save under application root directory.
         */
        
        NSString *databaseTemplateFilePath = [[NSBundle mainBundle] pathForResource:kMainDatabaseFileName
                                                                             ofType:kMainDatabaseFileExtension];
        if (databaseTemplateFilePath == nil)
        {
            NSLog(@"Invalid db template file path");
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
                NSLog(@"Database file restored");
                hasValidDatabaseFile = YES;
            }
        }
    }
    
     [self encryptAndExportDatabase];
    return hasValidDatabaseFile;
}


- (DatabaseQueue *)databaseQueue
{
    return self.databaseQueueObject;
}

- (NSString *)primaryDatabasePath
{
    NSString *databasePath = [[FileManager getRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kMainDatabaseFileName, kMainDatabaseFileExtension]];
    
    //NSLog(@"PrimaryDatabasePath Path : %@", databasePath);
    return databasePath;
}


- (NSString *)encryptionDatabasePath
{
    NSString *databasePath = [[FileManager getRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kDatabaseEncryptedDBName, kMainDatabaseFileExtension]];
    
   // NSLog(@"encryptionDatabasePath Path : %@", databasePath);
    
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

/**
 * @name   dbSecretKey
 *
 * @author Vipindas Palli
 *
 * @brief  Database Encryption Secret Key
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return String a secret key
 *
 */

- (NSString *)dbSecretKey
{
    return [SMDatabase dataBaseKey];
}

@end

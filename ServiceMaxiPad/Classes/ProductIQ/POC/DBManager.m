//
//  DBManager.m
//  ProductIQ
//
//  Created by Indresh M S on 4/19/15.
//  Copyright (c) 2015 ServiceMax. All rights reserved.
//

#import "DBManager.h"
#import "DatabaseManager.h"
#import "ProductIQManager.h"
#import "StringUtil.h"
#import "FactoryDAO.h"
#import "ModifiedRecordsDAO.h"
#import "SyncErrorConflictService.h"
#import "CacheManager.h"
#import "MobileDeviceSettingService.h"
#import "ModifiedRecordsDAO.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


@implementation DBManager


+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
//        [sharedInstance createDB];
//        [sharedInstance createTestTables];

    }
    return sharedInstance;
}

-(BOOL)createDB {
    NSString *docsDir;
    NSArray *dirPaths;
    sqlite3 *database = nil;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"priq.db"]];
    SXLogDebug(@"databasePath:%@", databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            sqlite3_close(database);
            
            return  isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    
    return isSuccess;
}

-(void)createTestTables
{
    //Create Tables
    //DROP TABLE IF EXISTS 'ClientCache';
    [self createTableWithQuery:@"CREATE TABLE 'ClientCache' ( 'RecordId' INTEGER PRIMARY KEY AUTOINCREMENT, 'Key'	VARCHAR UNIQUE, 'Value'	VARCHAR);"];
    
    [self createTableWithQuery:@"CREATE TABLE 'ClientSyncConflict' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT, 'Id'	VARCHAR UNIQUE, 'ObjectName'	VARCHAR, 'Type'	VARCHAR, 'Message'	VARCHAR, 'CreatedDate'	VARCHAR, 'Action'	VARCHAR);"];
    
    [self createTableWithQuery:@"CREATE TABLE 'ClientSyncLog' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT, 'Id'	VARCHAR UNIQUE, 'ObjectName'	VARCHAR, 'Operation'	VARCHAR, 'LastModifiedDate'	VARCHAR, 'Pending'	VARCHAR);"];
    
    [self createTableWithQuery:@"CREATE TABLE 'ClientSyncLogTransient' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT, 'Id'	VARCHAR UNIQUE, 'ObjectName'	VARCHAR, 'Operation'	VARCHAR, 'LastModifiedDate'	VARCHAR, 'Pending'	VARCHAR);"];
    
    [self createTableWithQuery:@"CREATE TABLE 'RecordName' ( 'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id'	VARCHAR UNIQUE,  'Name'	VARCHAR);"];
    
    [self createTableWithQuery:@"CREATE TABLE 'Translations' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'Key' VARCHAR,'Text' VARCHAR )"];
    
    [self createTableWithQuery:@"CREATE TABLE 'FieldDescribe' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'FieldName' VARCHAR,'DescribeResult' VARCHAR )"];
    [self createTableWithQuery:@"CREATE TABLE 'ObjectDescribe' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'ObjectName' VARCHAR UNIQUE ,'DescribeResult' VARCHAR )"];
    
    [self createTableWithQuery:@"CREATE TABLE 'Configuration' ( 'RecordId' INTEGER PRIMARY KEY  AUTOINCREMENT ,'Type' VARCHAR,'Key' VARCHAR,'Value' VARCHAR )"];
    
    [self createTableWithQuery:@"CREATE TABLE  'SVMXC__Sub_Location__c' (  'RecordId'	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id'	VARCHAR UNIQUE,  'OwnerId'	VARCHAR,  'IsDeleted'	VARCHAR,  'Name'	VARCHAR,  'CurrencyIsoCode'	VARCHAR,  'CreatedDate'	VARCHAR,  'CreatedById'	VARCHAR,  'LastModifiedDate'	VARCHAR,  'LastModifiedById'	VARCHAR,  'SystemModstamp'	VARCHAR,  'LastActivityDate '	VARCHAR,  'MayEdit '	VARCHAR,  'IsLocked '	VARCHAR,  'SVMXC__Account__c '	VARCHAR,  'SVMXC__City__c'	VARCHAR,  'SVMXC__Country__c'	VARCHAR,  'SVMXC__Email__c'	VARCHAR,  'SVMXC__Fax__c'	VARCHAR,  'SVMXC__Latitude__c'	VARCHAR,  'SVMXC__Location__c'	VARCHAR,  'SVMXC__Longitude__c'	VARCHAR,  'SVMXC__Parent__c'	VARCHAR,  'SVMXC__Phone__c'	VARCHAR,  'SVMXC__State__c'	VARCHAR,  'SVMXC__Street__c'	VARCHAR,  'SVMXC__Web_site__c'	VARCHAR,  'SVMXC__Zip__c'	VARCHAR );"];
    
//    [self executeQuery:@"CREATE TABLE  'Product2 ' (  'RecordId '	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id '	VARCHAR UNIQUE,  'Name '	VARCHAR,  'ProductCode '	VARCHAR,  'Description '	VARCHAR,  'IsActive '	VARCHAR,  'CreatedDate '	VARCHAR,  'CreatedById '	VARCHAR,  'LastModifiedDate '	VARCHAR,  'LastModifiedById '	VARCHAR,  'SystemModstamp '	VARCHAR,  'Family '	VARCHAR,  'CurrencyIsoCode '	VARCHAR,  'IsDeleted '	VARCHAR,  'MayEdit '	VARCHAR,  'IsLocked '	VARCHAR,  'SVMXC__Enable_Serialized_Tracking__c '	VARCHAR,  'SVMXC__Inherit_Parent_Warranty__c '	VARCHAR,  'SVMXC__Product_Cost__c '	VARCHAR,  'SVMXC__Product_Line__c '	VARCHAR,  'SVMXC__Select__c '	VARCHAR,  'SVMXC__Stockable__c '	VARCHAR,  'SVMXC__Tracking__c '	VARCHAR,  'SVMXC__Unit_Of_Measure__c '	VARCHAR,  'SVMXC__Replacement_Available__c '	VARCHAR,  'Brand__c '	VARCHAR,  'CommercialReference__c '	VARCHAR,  'DeviceType__c '	VARCHAR,  'EndOfCommercialisation_Date__c '	VARCHAR,  'EndOfLifeDate__c '	VARCHAR,  'Note__c '	VARCHAR,  'Range__c '	VARCHAR,  'SDHProductName__c '	VARCHAR,  'SKU__c '	VARCHAR,  'ServiceObsolecenseDate__c '	VARCHAR,  'Serviceability__c '	VARCHAR,  'SubType__c '	VARCHAR,  'Download_to_Mobile__c '	VARCHAR,  'Traceability__c '	VARCHAR,  'Type__c '	VARCHAR,  'UsefullLifeDuration__c '	VARCHAR,  'WithdrawalDate__c '	VARCHAR,  'Brand2__c '	VARCHAR,  'DeviceType2__c '	VARCHAR,  'ExtProductId__c '	VARCHAR,  'RangeLabel__c '	VARCHAR,  'SDHCategoryIdLabel__c '	VARCHAR,  'SDHCategoryId__c '	VARCHAR,  'SKULabel__c '	VARCHAR,  'SubTypeLabel__c '	VARCHAR,  'TECH_DownloadOffline__c '	VARCHAR,  'TECH_SDHQUERYAction__c '	VARCHAR,  'TypeLabel__c '	VARCHAR,  'CategoryId__c '	VARCHAR,  'SE_Material_Id__c '	VARCHAR,  'TECH_IsEnriched__c '	VARCHAR,  'TECH_SDHBRANDID__c '	VARCHAR,  'TECH_SDHCategoryId__c '	VARCHAR,  'TECH_SDHDEVICETYPEID__c '	VARCHAR,  'TECH_isCompetitor__c '	VARCHAR,  'BarcodeCategory__c '	VARCHAR,  'BarcodeNumber__c '	VARCHAR,  'BigMachines__Part_Number__c '	VARCHAR,  'BusinessType__c '	VARCHAR,  'CatalogReference__c '	VARCHAR,  'CommercialStatus__c '	VARCHAR,  'CommercialStatusDate__c '	VARCHAR,  'DimensionUnit__c '	VARCHAR,  'GrossWeight__c '	VARCHAR,  'Height__c '	VARCHAR,  'Length__c '	VARCHAR,  'NetWeight__c '	VARCHAR,  'ProductGDP__c '	VARCHAR,  'PublisherofGolden__c '	VARCHAR,  'SDHIntegrationID__c '	VARCHAR,  'SDHVersion__c '	VARCHAR,  'UniqueMaterialID__c '	VARCHAR,  'Volume__c '	VARCHAR,  'VolumeUnit__c '	VARCHAR,  'WeightUnit__c '	VARCHAR,  'Width__c '	VARCHAR,  'BusinessUnit__c '	VARCHAR,  'EndofCommercializationDate__c '	VARCHAR,  'FamilyName__c '	VARCHAR,  'FirstPublisherName__c '	VARCHAR,  'GDPGMR__c '	VARCHAR,  'GlobalOffer__c '	VARCHAR,  'ProductFamilyId__c '	VARCHAR,  'ProductFamilyName__c '	VARCHAR,  'ProductFamily__c '	VARCHAR,  'ProductLine__c '	VARCHAR,  'SchneiderUniqueReference__c '	VARCHAR,  'SourceKeyMaterial__c '	VARCHAR,  'SubstitutionReference__c '	VARCHAR,  'TECH_SDHVersion__c '	VARCHAR,  'Tech_PWP_Country__c '	VARCHAR,  'UnitofMeasure__c '	VARCHAR,  'isDiscontinued__c '	VARCHAR,  'isDocumentationFormula__c '	VARCHAR,  'isMarketingDocumentation__c '	VARCHAR,  'isOldFormula__c '	VARCHAR,  'isOld__c '	VARCHAR,  'isSparePartFormula__c '	VARCHAR,  'isSparePart__c '	VARCHAR,  'productgdpgmr__c '	VARCHAR,  'Cache_BusinessUnit__c '	VARCHAR,  'Cache_Family__c '	VARCHAR,  'Cache_ProductFamily__c '	VARCHAR,  'Cache_ProductLine__c '	VARCHAR,  'City__c '	VARCHAR,  'Tech_Concatenate__c '	VARCHAR,  'service_plan__c '	VARCHAR,  'RenewableService__c '	VARCHAR);"];
    
//    [self executeQuery:@"CREATE TABLE  'SVMXC__Installed_Product__c ' (  'RecordId '	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id '	VARCHAR UNIQUE,  'OwnerId '	VARCHAR,  'IsDeleted '	VARCHAR,  'Name '	VARCHAR,  'CurrencyIsoCode '	VARCHAR,  'RecordTypeId '	VARCHAR,  'CreatedDate '	VARCHAR,  'CreatedById '	VARCHAR,  'LastModifiedDate '	VARCHAR,  'LastModifiedById '	VARCHAR,  'SystemModstamp '	VARCHAR,  'LastActivityDate '	VARCHAR,  'MayEdit '	VARCHAR,  'IsLocked '	VARCHAR,  'LastViewedDate '	VARCHAR,  'LastReferencedDate '	VARCHAR,  'SVMXC__Access_Hours__c '	VARCHAR,  'SVMXC__Alternate_Company__c '	VARCHAR,  'SVMXC__Asset_Tag__c '	VARCHAR,  'SVMXC__Business_Hours__c '	VARCHAR,  'SVMXC__City__c '	VARCHAR,  'SVMXC__Company__c '	VARCHAR,  'SVMXC__Contact__c '	VARCHAR,  'SVMXC__Country__c '	VARCHAR,  'SVMXC__Date_Installed__c '	VARCHAR,  'SVMXC__Date_Ordered__c '	VARCHAR,  'SVMXC__Date_Shipped__c '	VARCHAR,  'SVMXC__Distributor_Company__c '	VARCHAR,  'SVMXC__Distributor_Contact__c '	VARCHAR,  'SVMXC__Installation_Notes__c '	VARCHAR,  'SVMXC__Last_Date_Shipped__c '	VARCHAR,  'SVMXC__Latitude__c '	VARCHAR,  'SVMXC__Longitude__c '	VARCHAR,  'SVMXC__Parent__c '	VARCHAR,  'SVMXC__Preferred_Technician__c '	VARCHAR,  'SVMXC__Product_Name__c '	VARCHAR,  'SVMXC__Product__c '	VARCHAR,  'SVMXC__Sales_Order_Number__c '	VARCHAR,  'SVMXC__Serial_Lot_Number__c '	VARCHAR,  'SVMXC__Site__c '	VARCHAR,  'SVMXC__State__c '	VARCHAR,  'SVMXC__Status__c '	VARCHAR,  'SVMXC__Street__c '	VARCHAR,  'SVMXC__Top_Level__c '	VARCHAR,  'SVMXC__Zip__c '	VARCHAR,  'SVMXC__Service_Contract_End_Date__c '	VARCHAR,  'SVMXC__Service_Contract_Exchange_Type__c '	VARCHAR,  'SVMXC__Service_Contract_Line__c '	VARCHAR,  'SVMXC__Service_Contract_Start_Date__c '	VARCHAR,  'SVMXC__Service_Contract__c '	VARCHAR,  'SVMXC__Warranty_End_Date__c '	VARCHAR,  'SVMXC__Warranty_Exchange_Type__c '	VARCHAR,  'SVMXC__Warranty_Start_Date__c '	VARCHAR,  'SVMXC__Warranty__c '	VARCHAR,  'ApplicableStandard__c '	VARCHAR,  'AssetCategory__c '	VARCHAR,  'AssetDescription__c '	VARCHAR,  'AssetIpAddress__c '	VARCHAR,  'AssetLinkType__c '	VARCHAR,  'AssetLink__c '	VARCHAR,  'AssetMACAdress__c '	VARCHAR,  'BreakingTechnology__c '	VARCHAR,  'CapacitorPowerUOM__c '	VARCHAR,  'CapacitorPowerkVAR__c '	VARCHAR,  'CommissioningDateInstallDate__c '	VARCHAR,  'ConstructionType__c '	VARCHAR,  'CustomerCommercialReference__c '	VARCHAR,  'CustomerCriticity__c '	VARCHAR,  'CustomerInstalledProductReference__c '	VARCHAR,  'CustomerSerialNumber__c '	VARCHAR,  'CustomerSoldTo__c '	VARCHAR,  'AssetCategory2__c '	VARCHAR,  'DecomissioningDate__c '	VARCHAR,  'DeliveryDate__c '	VARCHAR,  'DisplayFirmware__c '	VARCHAR,  'EndOfCommercialisationDate__c '	VARCHAR,  'EndOfInstalledProductLifeDate__c '	VARCHAR,  'EndOfInstalledProductShelfLife__c '	VARCHAR,  'GoldenAssetId__c '	VARCHAR,  'InstallationMode__c '	VARCHAR,  'InstalledProductCriticality__c '	VARCHAR,  'InstalledProductFirmwareVersion__c '	VARCHAR,  'InstalledProductNote__c '	VARCHAR,  'InstalledProductRevisionNumber__c '	VARCHAR,  'InstalledProductVersion__c '	VARCHAR,  'InstalledProduct__c '	VARCHAR,  'InvoiceNumber__c '	VARCHAR,  'LifeCycleStatusOfTheInstalledProduct__c '	VARCHAR,  'MadeInOfTheAsset__c '	VARCHAR,  'MadeInOfTheInstalledProduct__c '	VARCHAR,  'ManufacturingLotCode__c '	VARCHAR,  'ManufacturingRank__c '	VARCHAR,  'ManufacturingUnitDate__c '	VARCHAR,  'ManufacturingUnit__c '	VARCHAR,  'NumberOfPoles__c '	VARCHAR,  'PowerUOM__c '	VARCHAR,  'PowerkVA__c '	VARCHAR,  'PrimaryVoltage1__c '	VARCHAR,  'PrimaryVoltage2__c '	VARCHAR,  'PrimaryVoltageUOM__c '	VARCHAR,  'ProductLine__c '	VARCHAR,  'PurchaseOrderNumber__c '	VARCHAR,  'Quantity__c '	VARCHAR,  'Range__c '	VARCHAR,  'RatedCurrentUOM__c '	VARCHAR,  'RatedCurrent__c '	VARCHAR,  'RatedOperatingVoltageUOM__c '	VARCHAR,  'RatedOperatingVoltageUs__c '	VARCHAR,  'RatedVoltageUOM__c '	VARCHAR,  'RatedVoltage__c '	VARCHAR,  'RecommendedMaintenanceDate__c '	VARCHAR,  'ReferenceNumberOfRecallCampaign__c '	VARCHAR,  'RefurbishedProduct__c '	VARCHAR,  'RemoteDialingNumber__c '	VARCHAR,  'RemoteMonitoringSystemLink__c '	VARCHAR,  'Remote_Monitoring_Address__c '	VARCHAR,  'SE_Identification__c '	VARCHAR,  'SalesOrderNumber__c '	VARCHAR,  'SchneiderCommercialReference__c '	VARCHAR,  'SecondaryVoltage1__c '	VARCHAR,  'SecondaryVoltage2__c '	VARCHAR,  'SecondaryVoltageUOM__c '	VARCHAR,  'ServiceObsolecenseDate__c '	VARCHAR,  'Serviceability__c '	VARCHAR,  'SingleBrand__c '	VARCHAR,  'SubType__c '	VARCHAR,  'TECH_IsInstalledProductReadOnly__c '	VARCHAR,  'TECH_SDHGoldenVersion__c '	VARCHAR,  'TechnicalLevel__c '	VARCHAR,  'ThreePHParameterTable__c '	VARCHAR,  'ToDelete__c '	VARCHAR,  'Traceability__c '	VARCHAR,  'TransformerTechnology__c '	VARCHAR,  'TypeOfSubstation__c '	VARCHAR,  'Type__c '	VARCHAR,  'UniqueSEIdentification__c '	VARCHAR,  'WithdrawalDate__c '	VARCHAR,  'Brand2__c '	VARCHAR,  'BrandToCreate__c '	VARCHAR,  'DeviceType2__c '	VARCHAR,  'DeviceTypeToCreate__c '	VARCHAR,  'EndOfWarrantyOpportunityGenerated__c '	VARCHAR,  'EndingWarranty__c '	VARCHAR,  'LocationType__c '	VARCHAR,  'ObsolescenceOpportunityGenerated__c '	VARCHAR,  'Obsolete__c '	VARCHAR,  'ProductDescription__c '	VARCHAR,  'RangeToCreate__c '	VARCHAR,  'SDHCategoryId__c '	VARCHAR,  'SKUToCreate__c '	VARCHAR,  'ScoringPercentage__c '	VARCHAR,  'Scoring__c '	VARCHAR,  'SearchProduct__c '	VARCHAR,  'SubTypeToCreate__c '	VARCHAR,  'TECH_CreatedfromSFM__c '	VARCHAR,  'TECH_IsCoveredByContract__c '	VARCHAR,  'TECH_IsProductObsolete__c '	VARCHAR,  'TECH_SDHPublisherMaster__c '	VARCHAR,  'TypeToCreate__c '	VARCHAR,  'UnderContract__c '	VARCHAR,  'WarningMessage__c '	VARCHAR,  'WarrantyType__c '	VARCHAR,  'Category__c '	VARCHAR,  'CustomsCodeOfTheInstalledProduct__c '	VARCHAR,  'RequestSentToOPS__c '	VARCHAR,  'TECH_IPDeletionDate__c '	VARCHAR,  'TECH_MadeInOfTheAssetExtId__c '	VARCHAR,  'TECH_SDHBRANDID__c '	VARCHAR,  'TECH_SDHCategoryId__c '	VARCHAR,  'TECH_SDHDEVICETYPEID__c '	VARCHAR,  'TECH_CreateFromWS__c '	VARCHAR,  'Duplicate__c '	VARCHAR,  'ForceCreation__c '	VARCHAR,  'SchneiderBrand__c '	VARCHAR,  'Tech_DuplicateRecordID__c '	VARCHAR,  'UniqueIBfieldID__c '	VARCHAR,  'DeletionWarning__c '	VARCHAR,  'DuplicateWith__c '	VARCHAR,  'ReasonForDeletionMerger__c '	VARCHAR,  'ToBeDeletedMerge__c '	VARCHAR,  'TECH_ProductIdOfMasterPublisher__c '	VARCHAR,  'TECH_ProductPublisherOfGolden__c '	VARCHAR,  'Batch_RecordUpdate__c '	VARCHAR,  'TechnicalAttributePart1__c '	VARCHAR,  'ProductType__c '	VARCHAR,  'Tech_ConcatBRDType__c '	VARCHAR,  'VIPIcon__c '	VARCHAR,  'VIPStatus__c '	VARCHAR,  'WarrantyTriggerDate__c '	VARCHAR,  'PurchasedDate__c '	VARCHAR,  'WorkOrder__c '	VARCHAR,  'SVMXC__ProductIQTemplate__c '	VARCHAR,  'SVMXC__Sub_Location__c '	VARCHAR,  'DBID__c '	VARCHAR,  'ControlUnit__c '	VARCHAR);"];
    
    
//    [self executeQuery:@"CREATE TABLE  'SVMXC__Site__c ' (  'RecordId '	INTEGER PRIMARY KEY AUTOINCREMENT,  'Id '	VARCHAR UNIQUE,  'OwnerId '	VARCHAR,  'IsDeleted '	VARCHAR,  'Name '	VARCHAR,  'CurrencyIsoCode '	VARCHAR,  'RecordTypeId '	VARCHAR,  'CreatedDate '	VARCHAR,  'CreatedById '	VARCHAR,  'LastModifiedDate '	VARCHAR,  'LastModifiedById '	VARCHAR,  'SystemModstamp '	VARCHAR,  'LastActivityDate '	VARCHAR,  'MayEdit '	VARCHAR,  'IsLocked '	VARCHAR,  'LastViewedDate '	VARCHAR,  'LastReferencedDate '	VARCHAR,  'SVMXC__Account__c '	VARCHAR,  'SVMXC__City__c '	VARCHAR,  'SVMXC__Costed_at_value__c '	VARCHAR,  'SVMXC__Country__c '	VARCHAR,  'SVMXC__Email__c '	VARCHAR,  'SVMXC__Inventory_Account__c '	VARCHAR,  'SVMXC__IsPartnerRecord__c '	VARCHAR,  'SVMXC__IsPartner__c '	VARCHAR,  'SVMXC__Latitude__c '	VARCHAR,  'SVMXC__Longitude__c '	VARCHAR,  'SVMXC__Partner_Account__c '	VARCHAR,  'SVMXC__Partner_Contact__c '	VARCHAR,  'SVMXC__Service_Engineer__c '	VARCHAR,  'SVMXC__Site_Fax__c '	VARCHAR,  'SVMXC__Site_Phone__c '	VARCHAR,  'SVMXC__State__c '	VARCHAR,  'SVMXC__Stocking_Location__c '	VARCHAR,  'SVMXC__Street__c '	VARCHAR,  'SVMXC__Web_site__c '	VARCHAR,  'SVMXC__Zip__c '	VARCHAR,  'SVMXC__IsDefault_Delivery__c '	VARCHAR,  'SVMXC__IsDelivery_Location__c '	VARCHAR,  'SVMXC__IsGood_Stock__c '	VARCHAR,  'SVMXC__IsReceiving_Location__c '	VARCHAR,  'SVMXC__IsRepair_Location__c '	VARCHAR,  'SVMXC__IsStaging_Location__c '	VARCHAR,  'SVMXC__Location_Type__c '	VARCHAR,  'SVMXC__Parent__c '	VARCHAR,  'AccountName__c '	VARCHAR,  'AdditionalInfoAddressForFSE__c '	VARCHAR,  'AdditionalRequirements__c '	VARCHAR,  'AddressLine2__c '	VARCHAR,  'AirConditionning__c '	VARCHAR,  'AirDryerInTheSubstation__c '	VARCHAR,  'AutoAssignmentEnabled__c '	VARCHAR,  'CableTypeForNetwork__c '	VARCHAR,  'CustomerLocationNamingConvention__c '	VARCHAR,  'EnvironmentStressLevel__c '	VARCHAR,  'FifthPreferredTechnician__c '	VARCHAR,  'FourthPreferredTechnician__c '	VARCHAR,  'GoldenLocationId__c '	VARCHAR,  'HabilitationSubType__c '	VARCHAR,  'HabilitationType__c '	VARCHAR,  'Habilitation_Name__c '	VARCHAR,  'HealthAndSafety__c '	VARCHAR,  'Heating__c '	VARCHAR,  'HumidityValue__c '	VARCHAR,  'Inactive__c '	VARCHAR,  'IpAddressForNetwork__c '	VARCHAR,  'Language__c '	VARCHAR,  'LocalisationInformation__c '	VARCHAR,  'LocationAccessibiltyInformation__c '	VARCHAR,  'LocationCountry__c '	VARCHAR,  'LocationFunction__c '	VARCHAR,  'LocationNotes__c '	VARCHAR,  'LocationTechnicalCaracteristics__c '	VARCHAR,  'Location_Typology__c '	VARCHAR,  'NetworkSpeedUoM__c '	VARCHAR,  'TECH_CreateFromWS_IP__c '	VARCHAR,  'OverheadCabling__c '	VARCHAR,  'PUE__c '	VARCHAR,  'PreferredFSE__c '	VARCHAR,  'ProtocolOfNetwork__c '	VARCHAR,  'RaisedFloor__c '	VARCHAR,  'SecondPreferredFSE__c '	VARCHAR,  'SiteSpecificComments__c '	VARCHAR,  'SixthPreferredTechnician__c '	VARCHAR,  'StateProvince__c '	VARCHAR,  'SubType_Of_Location__c '	VARCHAR,  'TECH_Customer_Location__c '	VARCHAR,  'TECH_IsLocationReadOnly__c '	VARCHAR,  'TemperatureUnitOfMessure__c '	VARCHAR,  'Temperature__c '	VARCHAR,  'ThirdPreferredFSE__c '	VARCHAR,  'TimeZone__c '	VARCHAR,  'ToDelete__c '	VARCHAR,  'Valid__c '	VARCHAR,  'ValidationError__c '	VARCHAR,  'Ventilation__c '	VARCHAR,  'Certification_Business_Unit__c '	VARCHAR,  'Country_Name__c '	VARCHAR,  'NetworkSpeed__c '	VARCHAR,  'Parent_Hierarchy__c '	VARCHAR,  'PrimaryLocation__c '	VARCHAR,  'SAP_Instance__c '	VARCHAR,  'SAP_Plant_ID__c '	VARCHAR,  'SAP_Storage_Location_ID__c '	VARCHAR,  'Stock_Location_Type__c '	VARCHAR,  'TECH_CurrentUserSesa__c '	VARCHAR,  'TECH_IsCoveredByHRequirement__c '	VARCHAR,  'TECH_SDHGoldenVersion__c '	VARCHAR,  'TECH_SDHPublisherMaster__c '	VARCHAR,  'Top_Level_Location__c '	VARCHAR,  'Top_Level_Parent__c '	VARCHAR,  'Top_Parent__c '	VARCHAR,  'TECH_LocDeletionDate__c '	VARCHAR,  'TECH_LocSendToBatch__c '	VARCHAR,  'TECH_isAddressSynchedWithAccount__c '	VARCHAR,  'ValidTimeZone__c '	VARCHAR,  'SVMXC__Preferred_Business_Hours__c '	VARCHAR,  'VIPIcon__c '	VARCHAR,  'VIPStatus__c '	VARCHAR,  'TECH_CountryCode__c '	VARCHAR);"];

}

- (void)createTableWithQuery:(NSString*)query {
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        __block BOOL sucessFull = NO;
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            sucessFull = [db executeUpdate:query];
            
            if (!sucessFull)
            {
                if ([db hadError])
                {
                    NSLog(@"Create table failed with error : %@ ", [db lastErrorMessage]);
                }
            }
        }];
        
    }
}

-(NSMutableArray *)executeQuery:(NSString *)query {
    
    SXLogDebug(@"query:%@",query);
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
//        if ([query hasPrefix:@"UPDATE"])
//        {
//            MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
//            MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"IPAD018_SET016"];
//            self.isfieldMergeEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
//            if(self.isfieldMergeEnabled)
//            {
//                [self parseQuery:query];
//                
//            }
//            
//        }
        
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            if(![query hasPrefix:@"DROP"]) {
                SQLResultSet * resultSet = [db executeQuery:query];
                
                while ([resultSet next]) {
                    
                    NSDictionary * dict = [resultSet resultDictionary];
                    [records addObject:dict];
                    
                }
                [resultSet close];
                
            }
            
        }];
        
//        if([query hasPrefix:@"INSERT OR REPLACE INTO `ModifiedRecords`"])
//        {
//            MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
//            MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"IPAD018_SET016"];
//            self.isfieldMergeEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
//            if(self.isfieldMergeEnabled)
//            {
//                [self updateTheModifieDrecords];
//                
//            }
//            
//            
//        }
//        
    }
    return records;
    
    /*
     
     sqlite3 *database = nil;
     NSMutableArray *results = [[NSMutableArray alloc]init];
     
     const char *dbpath = [databasePath UTF8String];
     sqlite3_stmt *statement = nil;
     const char *query_stmt = [query UTF8String];
     
     if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
     
     int executeStatus = 0;
     
     if([query hasPrefix:@"DROP"]){
     executeStatus = sqlite3_exec(database, query_stmt, NULL, NULL, NULL);
     }else{
     executeStatus = sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
     if (executeStatus == SQLITE_OK) {
     
     // query is successfully executed
     int stepResult = sqlite3_step(statement), i = 0, cc = sqlite3_column_count(statement);
     NSString *name, *value;
     NSMutableDictionary *row = nil;
     while (stepResult == SQLITE_ROW) {
     row = [[NSMutableDictionary alloc] init];
     for(i = 0; i < cc; i++){
     name = [[NSString alloc] initWithUTF8String:sqlite3_column_name(statement, i)];
     value = [[NSString alloc] initWithUTF8String:sqlite3_column_text(statement, i)];
     [row setObject: value forKey: name];
     }
     
     [results addObject:row];
     
     // read next row data
     stepResult = sqlite3_step(statement);
     }
     
     sqlite3_finalize(statement);
     }
     }
     
     if(executeStatus != SQLITE_OK){
     NSLog(@"Error %s while executing the statement", sqlite3_errmsg(database));
     }
     
     sqlite3_close(database);
     }else{
     NSLog(@"Could not open database while executing the query!");
     }
     
     NSLog(@"records:%@", recordsTest);
     NSLog(@"results:%@",results);
     return results;
     
     */
}
- (void)parseQuery:(NSString *)query
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *beforeSaveDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *afterSaveDict = [[NSMutableDictionary alloc] init];
    
    NSArray *items = [query componentsSeparatedByString:@"UPDATE"];
    NSArray *array2 = [[items objectAtIndex:1] componentsSeparatedByString:@"SET"];
    NSString *tableName = [array2 objectAtIndex:0];
    NSString *str3 = [array2 objectAtIndex:1];
    NSArray *array3 = [str3 componentsSeparatedByString:@"WHERE"];
    NSArray *tempSfId = [[array3 objectAtIndex:1] componentsSeparatedByString:@"="];
    NSString *sFID = [tempSfId objectAtIndex:1];
    
    NSString *stringToParse = [array3 objectAtIndex:0];
    NSArray *keyValueArray = [stringToParse componentsSeparatedByString:@","];
    
    NSMutableDictionary *keyValueDict = [[NSMutableDictionary alloc] init];
    NSString *lastKey = nil;
    for(NSString *stringValue in keyValueArray)
    {
        NSArray *tempArray = [stringValue componentsSeparatedByString:@"="];
        if([tempArray count] >1)
        {
            NSString *valueString = [tempArray objectAtIndex:1];
            NSString *keyString = [tempArray objectAtIndex:0];
            
            NSString *newValue =[valueString stringByReplacingOccurrencesOfString:@"'" withString:@""];
            keyString = [keyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            keyString =[keyString stringByReplacingOccurrencesOfString:@"'" withString:@""];

            [keyValueDict setObject:newValue forKey:keyString];
            lastKey = stringValue;
            
        }
        else
        {
            NSString *lastValue = [keyValueDict objectForKey:lastKey];
            lastValue = [NSString stringWithFormat:@"%@, %@",lastValue,stringValue];
            [keyValueDict setObject:lastValue forKey:stringValue];

        }
        
    }
    NSArray *keyArray = [keyValueDict allKeys];
    // NSString *stringQuery = [keyArray componentsJoinedByString:@","];
    NSString *sfIdNew = [sFID stringByReplacingOccurrencesOfString:@"'" withString:@""];
    sfIdNew = [sfIdNew stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // NSString *finalQuery = [NSString stringWithFormat:@"SELECT %@ , FROM %@ Where Id = %@", stringQuery,tableName,sfIdNew];
    // NSString *strQuery = finalQuery;
    NSString *newTableName = [tableName  stringByReplacingOccurrencesOfString:@"`" withString:@""];
    newTableName = [newTableName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *newKeyValueDict =  [self getRecordsForFields:keyArray forObjectname:newTableName
                                                       andSFId:sfIdNew];
    if([keyArray count] >0)
    {
        [beforeSaveDict setObject:sfIdNew forKey:@"Id"];
        [afterSaveDict setObject:sfIdNew forKey:@"Id"];
    }
    for (NSString *tempstring in keyArray)
    {
        NSString *afterSaveValue = [keyValueDict objectForKey:tempstring];
        NSString *beforeSaveValue = [newKeyValueDict objectForKey:tempstring];
        if(![beforeSaveValue isEqualToString:afterSaveValue])
        {
            if(![StringUtil isStringEmpty:beforeSaveValue])
            {
                {
                   if(![StringUtil isStringEmpty:afterSaveValue])
                   {
                       [beforeSaveDict setObject:beforeSaveValue forKey:tempstring];
                       [afterSaveDict setObject:afterSaveValue forKey:tempstring];
                   }

                }
               
            }
           
        }
        
    }
    if([beforeSaveDict count] >1)
    {
        [jsonDict setObject:beforeSaveDict forKey:@"BEFORE_SAVE"];
        [jsonDict setObject:afterSaveDict forKey:@"AFTER_SAVE"];
        
        
    }
    
    
    NSDictionary *previousDict = [self checkFormodifiedFiledJsonString:nil withSFId:sfIdNew andObjectName:newTableName];
    if(previousDict != nil)
    {
        [self compareAndinsertDict:jsonDict andOldDict:previousDict withSFId:sfIdNew];
    }
    else
    {
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&err];
        NSString * myJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *strJsonString = myJsonString;
        NSDictionary   *jsonDictionary1    = [NSJSONSerialization JSONObjectWithData:[myJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        NSString *str1 = myJsonString;
        [self insertDictionary:myJsonString withSFId:sfIdNew];

    }
    
}
- (void)compareAndinsertDict:(NSDictionary *)jsonDict andOldDict:(NSDictionary *)previousDict withSFId:(NSString *)sfID
{
    NSMutableDictionary *currentDict = [[NSMutableDictionary alloc] init];
    
    NSDictionary *beforeNewModification = [jsonDict objectForKey:@"BEFORE_SAVE"];
    NSDictionary *beforPrevModification = [previousDict objectForKey:@"BEFORE_SAVE"];
    NSMutableDictionary *currentBeforeModification = [[NSMutableDictionary alloc] init];
    NSArray *allkeys = [beforeNewModification allKeys];
    NSArray *beforeoldKeys = [beforPrevModification allKeys];
    for(NSString *key in allkeys)
    {
        if([beforeoldKeys containsObject:key])
        {
            [currentBeforeModification setObject:[beforPrevModification objectForKey:key]  forKey:key];
        }
        else
        {
            [currentBeforeModification setObject:[beforeNewModification objectForKey:key] forKey:key];
        }
    }
    
    
    
    NSDictionary *afterNewModification = [jsonDict objectForKey:@"AFTER_SAVE"];
    NSDictionary *afterPrevModification = [previousDict objectForKey:@"AFTER_SAVE"];
    
    NSMutableDictionary *currentAfterModification = [[NSMutableDictionary alloc] init];
    
    NSArray *afterNewAllkeys = [afterNewModification allKeys];
    NSArray *afterOldKeys = [afterPrevModification allKeys];
    
    for(NSString *keys in afterNewAllkeys)
    {
        if([afterOldKeys containsObject:keys])
        {
            [currentAfterModification setObject:[afterNewModification objectForKey:keys] forKey:keys];
            
        }
        
        else
        {
            [currentAfterModification setObject:[afterPrevModification objectForKey:keys] forKey:keys];
            
        }
        
    }
    
    [currentDict setObject:currentBeforeModification forKey:@"BEFORE_SAVE"];
    [currentDict setObject:afterNewModification forKey:@"AFTER_SAVE"];
    
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:currentDict options:0 error:&err];
    NSString * myJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self insertDictionary:myJsonString withSFId:sfID];
    
    
    
}
- (NSDictionary *)checkFormodifiedFiledJsonString:(NSString *)jsonString withSFId:(NSString *)sfid andObjectName:(NSString *)objName
{
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    
    ModifiedRecordModel *model = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordIdForProductIQ:sfid andSfId:sfid];
   NSString  *existingModifiedFields = model.fieldsModified;
    NSDictionary *jsonDictionary;
    NSError * error = nil;
    
    if(![StringUtil isStringEmpty:existingModifiedFields])
    {
        
        jsonDictionary    = [NSJSONSerialization JSONObjectWithData:[existingModifiedFields dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
    }
//    else
//    {
//        BOOL hasConflictRecordFound = NO;
//        
//        SyncErrorConflictService *conflictService = [[SyncErrorConflictService alloc]init];
//        hasConflictRecordFound = [conflictService isConflictFoundForObject:objName withSfId:sfid];
//        
//        if (hasConflictRecordFound)
//        {
//            // Found conflict mark on existing records. Lets consider conflict record as previous change
//            existingModifiedFields = [conflictService fetchExistingModifiedFieldsJsonFromConflictTableForSfId:sfid andObjectName:objName];
//            jsonDictionary    = [NSJSONSerialization JSONObjectWithData:[existingModifiedFields dataUsingEncoding:NSUTF8StringEncoding]
//                                                                options:NSJSONReadingMutableContainers
//                                                                  error:&error];
//            
//        }
   // }
    if([jsonDictionary count] >0)
    {
        return jsonDictionary;
    }
    else
    {
        return nil;
    }
}

- (void)insertDictionary:(NSString * )jsonString withSFId:(NSString *)sfId
{
    CacheManager *cache = [CacheManager sharedInstance];
    [cache  pushToCache:sfId byKey:@"currentSFID"];
    [cache pushToCache:jsonString byKey:@"modifiedString"];
//    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
//    ModifiedRecordModel *model = [[ModifiedRecordModel alloc] init];
//    
//    model.sfId = sfId;
//    model.fieldsModified = jsonString;
//    model.operation = @"UPDATE";
//
//     BOOL resultStatus = [modifiedRecordService saveRecordModel:model];
}
-(void)updateFields:(NSString *)jsonString andSfId:(NSString *)sfid
{
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    ModifiedRecordModel *model = [[ModifiedRecordModel alloc] init];
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:@"sfId"
                                                   operatorType:SQLOperatorEqual
                                                  andFieldValue:sfid];
    model.fieldsModified = jsonString;

    [modifiedRecordService updateRecords:@[model] withFields:@[@"fieldsModified"]
                            withCriteria:@[criteria]];

}
- (NSArray *)getFiledsforQuery:(NSString *)query
{
    return nil;
}

- (NSDictionary *)getRecordsForFields:(NSArray *)fields
                   forObjectname:(NSString *)tableName
                  andSFId:(NSString *)andSFId
{
    
    ProductIQManager *model = [ProductIQManager sharedInstance];
    NSDictionary *dict = [model getProdIQTxFetcRequestParamsForRequestCount1:fields
                                                                andTableName:tableName andId:andSFId];
    return dict;
    
}
- (void)updateTheModifieDrecords
{
    CacheManager *cache = [CacheManager sharedInstance];
    NSString *sfID = [cache getCachedObjectByKey:@"currentSFID"];
    NSString *modifiedString = [cache getCachedObjectByKey:@"modifiedString"];
    [self updateFields:modifiedString andSfId:sfID];
    [self clearCache];
    
}
- (void)clearCache
{
    CacheManager *cache = [CacheManager sharedInstance];
    [cache clearCacheByKey:@"currentSFID"];
    [cache clearCacheByKey:@"modifiedString"];

}


@end

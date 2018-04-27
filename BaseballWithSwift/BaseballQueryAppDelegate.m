//
//  BaseballQueryAppDelegate.m
//  BaseballQuery
//
//  Created by Matthew Jones on 4/20/10.
//  Copyright Bulbous Ventures LLC 2010-2018. All rights reserved.
//

@import CoreData;
#import "BaseballQueryAppDelegate.h"
#import "AllPlayers.h"
#import <sys/xattr.h>
#import <StoreKit/StoreKit.h>
#import "ShakeNavController.h"
#import "InAppPurchaseController.h"
#import "BaseballWithSwift-Swift.h"

@implementation BaseballQueryAppDelegate

#pragma mark Core Data stack

/*
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to 
 the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = _persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setUndoManager:nil];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    };
    return _managedObjectContext;
}

//
// managedObjectModel - Returns the managed object model for the application.
//
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    // Always use the same model. Start off with latest season disabled, allow in-app purchase to unlock it.
    NSURL *momURL = [[NSBundle mainBundle] URLForResource:MODEL_FILENAME_PREFIX withExtension:@"mom"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    return _managedObjectModel;
}

-(void)setPersistentStoreWithURL:(NSURL *)databaseURL
{
    self.managedObjectContext = nil; // Force getting a new context.
    self.managedObjectModel = nil; // Also force a new model.
	NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString *pathFromURL = [databaseURL path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathFromURL])
        // Set journal_mode to DELETE to disable WAL mode. This is recommended for read-only db's.
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:databaseURL options:@{NSReadOnlyPersistentStoreOption: @YES,NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}} error:&error];
}

#pragma mark Database location and installation

- (NSString *) databaseDocumentsDirectory 
{
    NSString *docDirectoryPathToReturn = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docDirectoryPathToReturn = paths[0];
    return docDirectoryPathToReturn;
}

 /* This year's edition app is free. It should clear out any older database files
 when it starts up. Then make sure the current DB is unzipped. The user
 has either paid for the latest season or not. If not, set latest_year to
 one previous and there is no access to latest year. If so, set it to latest.
 */

-(NSString *)touchFileName
{
    // Returns name of file name that is 'touched' to indicate
    // user has purchased the latest data year.
    // This works without change for each year!
    return [NSString stringWithFormat:@"Purchased_%d",LATEST_DATA_YEAR];
}

//
// installLatestDatabase - called by InAppPurchaseObserver when the user
//    has purchased the latest version.
//
-(void)installLatestDatabase
{
    if (_latest_year_in_database < LATEST_DATA_YEAR) {
        // Don't change any database stuff. Already have the 2014 db unzipped.
        _latest_year_in_database = LATEST_DATA_YEAR;
        NSString *touchFileName = [self touchFileName];
        NSFileManager *fMan = [NSFileManager defaultManager];
        NSString *touchFileNamePath = [NSString pathWithComponents:@[[self databaseDocumentsDirectory],touchFileName]];
        // Not sure if it can be null so give it a bit of data.
        NSString *content = [NSString stringWithFormat:@"User purchased %d stats year.",LATEST_DATA_YEAR];
        NSData *fileContents = [content dataUsingEncoding:NSUTF8StringEncoding];
        // Create a file Documents/TOUCH_FILENAME (eg. Purchased_2014).
        [fMan createFileAtPath:touchFileNamePath contents:fileContents attributes:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteBuyButton" object:nil]; // Tell view controller to delete Buy button.
    }
}

//
// sqliteFileExistsInDocumentsDirectory -
// Test whether (uncompressed) database file exists, ie. <namePrefix>.sqlite
//
-(BOOL)sqliteFileExistsInDocumentsDirectory:(NSString *)namePrefix
{
    NSFileManager *fMan = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *lsDocumentsDir = [fMan contentsOfDirectoryAtPath:[self databaseDocumentsDirectory] error:&error];
    NSString *sqliteFile = [NSString stringWithFormat:@"%@.sqlite",namePrefix];
	for (NSString *thingInDir in lsDocumentsDir) {
        if ([thingInDir isEqualToString:sqliteFile]) {
            return YES;
        }
    }
    return NO;
}

//
// useDatabaseFileWithName - Start the wheels of core data in motion
//   using this database name.
//
-(void)useDatabaseFileWithName:(NSString *)wholeFileName
{
    [self setPersistentStoreWithURL:[NSURL fileURLWithPathComponents:@[[self databaseDocumentsDirectory],wholeFileName]]];
}

//
// useDatabaseFileWithNamePrefix - given name add .sqlite suffix
//   and get the persistent store etc.
//
-(void)useDatabaseFileWithNamePrefix:(NSString *)namePrefix
{
    [self useDatabaseFileWithName:[NSString stringWithFormat:@"%@.sqlite",namePrefix]];
}

//
// addSkipBackupAttributeToItemAtURL - Exclude unzipped database file
//    from the user's iTunes/iCloud backups.
//
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    // Set the old flag (extended attribute).
    // *** Not supposed to be needed in iOS > 5.0 but it seems to be. @WWDC 6-2012
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    // Also the new flag (resource value).
    NSError *error = nil;
    [URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    return error == nil;
}

//
// useCompressedDatabaseFileWithNamePrefix - given prefix add .sqlite.zip,
//  unzip it, and start using it.
//
-(void)useCompressedDatabaseFileWithNamePrefix:(NSString *)namePrefix setPersistentStore:(BOOL)shouldSetPersistentStore
{
    NSString *namePrefixSqliteSuffix = [NSString stringWithFormat:@"%@.sqlite",namePrefix];
    NSString *zipPath = [[NSBundle mainBundle] pathForResource:namePrefixSqliteSuffix ofType:@"zip"];
    // File must already exist!
    NSString *tempDirectoryForUnzip = NSTemporaryDirectory();
    [SSZipArchive unzipFileAtPath:zipPath toDestination:tempDirectoryForUnzip];
    NSFileManager *fMan = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *temporaryFullPath = [NSString pathWithComponents:@[tempDirectoryForUnzip,namePrefixSqliteSuffix]];
    NSString *destinationPath = [NSString pathWithComponents:@[[self databaseDocumentsDirectory],namePrefixSqliteSuffix]];
    if ([fMan fileExistsAtPath:destinationPath]) { // Need to manually delete destination first.
        [fMan removeItemAtPath:destinationPath error:&error];
    }
    [fMan moveItemAtPath:temporaryFullPath toPath:destinationPath error:&error];
    // Set Do Not Back Up attribute.
    // *** Apple did not approve update unless this was set, due to 49+ KB file size of uncompressed file.
    // Note that if the system removes the file (hopefully not while our application is
    // running), the next time our app starts up, we will just uncompress it again.
    // This version handles differences between iOS 5.01 and earlier and 5.1 and later.
    // This seems to still work in 2016!
    NSURL *destinationPathURL = [NSURL fileURLWithPath:destinationPath];
    [self addSkipBackupAttributeToItemAtURL:destinationPathURL];
    if (shouldSetPersistentStore)
        // Following sets persistent store from URL.
        [self useDatabaseFileWithNamePrefix:namePrefix];
}

//
// setupDatabase - initial database setup on application startup or after database download and uncompress. Sets up persistentStoreCoordinator and managedObjectModel.
// See if DATABASE_FILENAME_PREFIX.sqlite is there (eg. Stats_2016a.sqlite). If so, leave it and use it. If not, delete all *sqlite and unzip this one.
// Note that if we have an update with suffix name like Stats_2016a.sqlite.zip, the contained file needs to have the suffix eg. Stats_2016a.sqlite. Make sure to change the name before compressing after building the db with the importer tool.

-(void)setupDatabase
{
    // Do ls on documents dir. Check all *.sqlite files.
    // Delete all files not named DATABASE_FILENAME_PREFIX.sqlite
    // If DATABASE_FILENAME_PREFIX.sqlite is there, use it. If not, unzip it from
    // app bundle and start using it.
    NSFileManager *fMan = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *databaseDirectoryPath = [self databaseDocumentsDirectory]; // separate line is easier to debug.
    NSArray *lsDocs = [fMan contentsOfDirectoryAtPath:databaseDirectoryPath error:&error];
    BOOL latest_sqlite_is_there = NO;
    for (NSString *docsFile in lsDocs) {
        // Makes it 'ls *sqlite'. Remove any old db file, and mark if latest one is there.
        if ([docsFile length] < 6) continue; // Avoid a crash if weird file laying around. This happened once.
        if ([[docsFile substringFromIndex:[docsFile length]-6] isEqualToString:@"sqlite"]) {
            if (![[docsFile substringToIndex:[docsFile length]-7] isEqualToString:DATABASE_FILENAME_PREFIX]) {
                // Found a *.sqlite file that doesn't match DATABASE_FILENAME_PREFIX.sqlite - delete it.
                NSString *docsFilePath = [NSString pathWithComponents:@[[self databaseDocumentsDirectory],docsFile]];
                // Remove all *.sqlite files except DATABASE_FILENAME_PREFIX.sqlite
                [fMan removeItemAtPath:docsFilePath error:&error];
            } else latest_sqlite_is_there = YES; // Keep the good one.
        }
    }
    if (latest_sqlite_is_there)
        // Use already unzipped DATABASE_FILENAME_PREFIX.sqlite
        [self useDatabaseFileWithNamePrefix:DATABASE_FILENAME_PREFIX];
    else
        // Unzip DATABASE_FILENAME_PREFIX.sqlite.zip
        [self useCompressedDatabaseFileWithNamePrefix:DATABASE_FILENAME_PREFIX setPersistentStore:YES];
    // But if purchased, there will be a touch file sitting around.
    NSString *touchFileName = [self touchFileName];
    NSString *touchFileNamePath = [NSString pathWithComponents:@[[self databaseDocumentsDirectory],touchFileName]];
    if ([fMan fileExistsAtPath:touchFileNamePath]) {
        _latest_year_in_database = LATEST_DATA_YEAR;
    } else {
        _latest_year_in_database = LATEST_DATA_YEAR - 1;
    }
}

-(BOOL)allowNewInLatestYear
{
    return (_latest_year_in_database == LATEST_DATA_YEAR);
}

-(BOOL)excludeLatestYear
{
    return (_latest_year_in_database < LATEST_DATA_YEAR);
}

#pragma mark Start Here

//
// application didFinishLaunchingWithOptions - start here!
//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Do HockeyApp wrapper stuff. This is all we need to do for crash-report-only version of HA.
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"10dbd8d97b806217d054fa06c762d905"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator
     authenticateInstallation];
    [self setupApplication];
    return YES;
}

- (void)setupApplication {
    [self setupDatabase];
    RootTabBarController *froot = (RootTabBarController *)self.window.rootViewController; // Storyboard set up initial controller for us.
    froot.managedObjectContext = self.managedObjectContext;
    // Earliest opportunity: do player fetch which takes a long time.
    AllPlayers *ourAllPlayersTVC = (AllPlayers *)[(UINavigationController *)froot.viewControllers[1] topViewController];
    ourAllPlayersTVC.managedObjectContext = self.managedObjectContext;
    [ourAllPlayersTVC fetchAllPlayersInBackground];
    self.observer = [[InAppPurchaseObserver alloc] init]; // Keep around so it doesn't get released.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:_observer];
    // Also start the in-app process controller so that it gets product info as soon as possible. This way we can display the (localized) price right away when the user presses the Buy button, for example.
    [InAppPurchaseController sharedInstance];
}

@end


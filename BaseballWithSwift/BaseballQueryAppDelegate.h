//
//  BaseballQueryAppDelegate.h
//  BaseballQuery
//
//  Created by Matthew Jones on 4/20/10.
//  Copyright Bulbous Ventures 2010-2018. All rights reserved.
//


@import UIKit;
#import "RootTabBarController.h"
#import "ZipArchive.h"
#import "InAppPurchaseObserver.h"
@import HockeySDK;
#import "ThisYear.h"

@protocol SettingsTableCalls
-(void)segueToAbout;
-(void)segueToTips;
-(void)closeSettingsView;
@end

@interface BaseballQueryAppDelegate : NSObject <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) NSInteger latest_year_in_database;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) InAppPurchaseObserver *observer;

-(NSString *)databaseDocumentsDirectory;
-(void)installLatestDatabase;
-(void)useCompressedDatabaseFileWithNamePrefix:(NSString *)namePrefix setPersistentStore:(BOOL)shouldSetPersistentStore;
-(BOOL)allowNewInLatestYear;
-(BOOL)excludeLatestYear;

@end



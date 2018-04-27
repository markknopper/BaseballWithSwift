//
//  RetrosheetController.h
//
//  Created by Mark Knopper on 5/29/11.
//  Copyright 2011-2014 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
@class Master;

@interface RetrosheetController : NSObject

@property (nonatomic) NSManagedObjectContext *managedObjectContext; // The regular one.

 @property (nonatomic, strong) NSManagedObjectContext *retrosheetManagedObjectContext;
 @property (nonatomic, strong) NSManagedObjectModel *retrosheetManagedObjectModel;
 @property (nonatomic, strong) NSPersistentStoreCoordinator *retrosheetPersistentStoreCoordinator;

+(RetrosheetController *)sharedInstance;
-(NSString *)teamNameFromRetroTeamID:(NSString *)retroTeamID yearID:(NSString *)yearID;
-(NSString *)retroIDUsingNameFromMaster:(Master *)master;

@end

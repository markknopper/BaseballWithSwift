//
//  RetrosheetController.m
//
//  Created by Mark Knopper on 5/29/11.
//  Copyright 2011-2014 Bulbous Ventures LLC. All rights reserved.
//

#import "RetrosheetController.h"
#import "BaseballQueryAppDelegate.h"
#import "Teams+Query.h"
#import "Master+Query.h"
#import "RetroID.h"
#import "ThisYear.h"

@implementation RetrosheetController

// The simplest singleton I could find.
+(RetrosheetController *)sharedInstance
{
	static RetrosheetController *this = nil;
	if (!this)
		this = [[RetrosheetController alloc] init];
	return this;
}

- (NSManagedObjectModel *)retrosheetManagedObjectModel {
    if (!_retrosheetManagedObjectModel) {
        NSURL *retroModelURL = [[NSBundle mainBundle] URLForResource:RETROSHEET_MODEL_FILENAME_PREFIX withExtension:@"mom"];
        //    NSString *path = [[NSBundle mainBundle] pathForResource:MODEL_FILENAME_PREFIX ofType:@"mom"];

        _retrosheetManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:retroModelURL];
    }
    return _retrosheetManagedObjectModel;
}

- (NSPersistentStoreCoordinator *) retrosheetPersistentStoreCoordinator {
    if (_retrosheetPersistentStoreCoordinator) return _retrosheetPersistentStoreCoordinator;
    _retrosheetPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self retrosheetManagedObjectModel]];
    // First assume sqlite file is in docs directory.
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *retrosheetDatabaseFileName = [NSString stringWithFormat:@"%@.sqlite",RETROSHEET_FILENAME_PREFIX];
    NSString *retroPath = [[appDel databaseDocumentsDirectory] stringByAppendingPathComponent:retrosheetDatabaseFileName];
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:retroPath]) {
        // Uncompress it.
        [appDel useCompressedDatabaseFileWithNamePrefix:RETROSHEET_FILENAME_PREFIX setPersistentStore:NO];
    }
    [_retrosheetPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:retroPath] options:@{NSReadOnlyPersistentStoreOption: @YES,NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}} error:&error];
    return _retrosheetPersistentStoreCoordinator;
}

//
// retrosheetManagedObjectContext - Get our own MOC using separate persistent store.
//
-(NSManagedObjectContext *)retrosheetManagedObjectContext
{
    if (_retrosheetManagedObjectContext) return _retrosheetManagedObjectContext;
    _retrosheetManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    
    //_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //[_managedObjectContext setUndoManager:nil];
    //[_managedObjectContext setPersistentStoreCoordinator: coordinator];

    
    [_retrosheetManagedObjectContext setUndoManager:nil];
    [_retrosheetManagedObjectContext setPersistentStoreCoordinator: self.retrosheetPersistentStoreCoordinator];
    return _retrosheetManagedObjectContext;
}

#pragma Baseball specific stuff involving Retrosheet database

-(NSString *)teamNameFromRetroTeamID:(NSString *)retroTeamID yearID:(NSString *)yearID
{
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *regularMOC = [appDel managedObjectContext];
    NSFetchRequest *teamDateFetch = [NSFetchRequest new];
    NSEntityDescription *teamEnt = [NSEntityDescription entityForName:@"Teams" inManagedObjectContext:regularMOC];
    [teamDateFetch setEntity:teamEnt];
    NSPredicate *teamDatePred = [NSPredicate predicateWithFormat:@"teamIDretro == %@ AND yearID == %@",retroTeamID,yearID];
    [teamDateFetch setPredicate:teamDatePred];
    NSError *error = nil;
    NSArray *teamAnswers = [regularMOC executeFetchRequest:teamDateFetch error:&error];
    NSString *teamNameToReturn = @"";
    if ([teamAnswers count]>0) {
        Teams *ourTeam = teamAnswers[0];
        teamNameToReturn = ourTeam.name;
    }
    return teamNameToReturn;
}

// In case of not having a master.retroID, do risky move
// of finding a player with the same name in the Retro db.
// This will be right in all cases except where it is wrong.
// But better than being so cautious that we don't show anything?
-(NSString *)retroIDUsingNameFromMaster:(Master *)master
{
    NSString *retroIDToReturn = nil;
    NSFetchRequest *emergencyFetch = [NSFetchRequest fetchRequestWithEntityName:@"RetroID"];
    NSManagedObjectContext *retroMOC = [[RetrosheetController sharedInstance] retrosheetManagedObjectContext];
    NSPredicate *emergencyPred = [NSPredicate predicateWithFormat:@"nameFirst == %@ AND nameLast == %@",master.nameFirst,master.nameLast];
    [emergencyFetch setPredicate:emergencyPred];
    NSError *error = nil;
    NSArray *hopefullyOnlyOneRetroID = [retroMOC executeFetchRequest:emergencyFetch error:&error];
    if ([hopefullyOnlyOneRetroID count]>0) retroIDToReturn = ((RetroID *)hopefullyOnlyOneRetroID[0]).id;
    return retroIDToReturn;
}

@end

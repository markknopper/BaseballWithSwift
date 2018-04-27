//
//  TransactionsTVC.m
//  BaseballQuery
//
//  Created by Mark Knopper on 9/17/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "TransactionsTVC.h"
#import "RetrosheetController.h"
#import "Transaction+Query.h"
#import "BaseballQueryAppDelegate.h"
#import "Master+Query.h"
#import "RetroID.h"

@implementation TransactionsTVC

// Class routine for view controllers to determine if they need a button.
// Takes some time for button to show but this looks kind of cool.
+(BOOL)anyTransactionsForPlayer:(BQPlayer *)player
{
    BOOL any_to_return = FALSE;
    // Should be a simple question. But playerID needs to be translated to retroID.
    NSString *ourRetroID = player.master.retroID;
    if (!ourRetroID || [ourRetroID isEqualToString:@" "]) {
        // Don't have a retroID.
        ourRetroID = [[RetrosheetController sharedInstance] retroIDUsingNameFromMaster:player.master];
    }
    if (ourRetroID && ![ourRetroID isEqualToString:@" "]) {
        NSFetchRequest *transFetch = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
        NSPredicate *transPred = [NSPredicate predicateWithFormat:@"playerIDOrName == %@",ourRetroID];
        [transFetch setPredicate:transPred];
        NSError *error = nil;
        any_to_return = ([[[RetrosheetController sharedInstance] retrosheetManagedObjectContext] countForFetchRequest:transFetch error:&error] > 0);
    }
    return any_to_return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Assume year & player have been set up.
    NSManagedObjectContext *mOC =  [[RetrosheetController sharedInstance] retrosheetManagedObjectContext];
    NSFetchRequest *transFetch = [NSFetchRequest new];
    NSEntityDescription *transEntity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:mOC];
    [transFetch setEntity:transEntity];
    // Translate playerID to retroID for retrosheet lookup.
    Master *playerMaster = _player.master;
    NSString *retroID = playerMaster.retroID;
    // If retroID is missing, which occurs sometimes, what to do?
    // How about looking up player by first/last in RetroID.
    if (!retroID || [retroID isEqualToString:@" "]) {
        // Geez this takes a fair amount of error recovery.
        retroID = [[RetrosheetController sharedInstance] retroIDUsingNameFromMaster:_player.master];
        if (!retroID || [retroID isEqualToString:@" "]) return; // I got nothin'.
    }
    NSPredicate *transPred = [NSPredicate predicateWithFormat:@"playerIDOrName == %@",retroID];
    self.title = @"All Transactions";
    if (_transactionID) { // This means get all transactions for this ID.
        self.title = @"Transaction";
        transPred = [NSPredicate predicateWithFormat:@"transactionID == %@",_transactionID];
    } else {
        // If year is given, query only for transactions for this year.
        if (_year && [_year integerValue]>0) {
            transPred = [NSPredicate predicateWithFormat:@"playerIDOrName == %@ AND yearID == %@",retroID,[_year description]];
            self.title = [NSString stringWithFormat:@"%@ Transactions",[_year description]];
        }
    }
    [transFetch setPredicate:transPred];
    [transFetch setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"primaryDate" ascending:YES]]];
    NSError *error = nil;
    self.transactions = [mOC executeFetchRequest:transFetch error:&error];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number_of_rows_to_return = [_transactions count];
    if (number_of_rows_to_return == 0) number_of_rows_to_return = 1;
    return number_of_rows_to_return;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If _transactionID version of table, set title to date.
    NSString *titleToReturn = @"";
    if (_transactionID) {
        NSDate *firstTransactionDate = ((Transaction *)_transactions[0]).primaryDate;
        titleToReturn = [NSDateFormatter localizedStringFromDate:firstTransactionDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    }
    return titleToReturn;
}

-(NSString *)fullNameForRetroID:(NSString *)retroID
{
    RetrosheetController *rc = [RetrosheetController sharedInstance];
    NSManagedObjectContext *retroMOC = rc.retrosheetManagedObjectContext;
    NSFetchRequest *retroIDFetch = [NSFetchRequest new];
    NSEntityDescription *retroIDEntity = [NSEntityDescription entityForName:@"RetroID" inManagedObjectContext:retroMOC];
    [retroIDFetch setEntity:retroIDEntity];
    NSPredicate *retroPred = [NSPredicate predicateWithFormat:@"id == %@",retroID];
    [retroIDFetch setPredicate:retroPred];
    NSError *error = nil;
    NSArray *oneRetroID = [retroMOC executeFetchRequest:retroIDFetch error:&error];
    RetroID *retroIDRecord = oneRetroID[0];
    return [NSString stringWithFormat:@"%@ %@",retroIDRecord.nameFirst,retroIDRecord.nameLast];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TransactionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ([_transactions count] == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"No transactions for player.";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    Transaction *ourTransaction = _transactions[indexPath.row];
    NSDate *primaryDate = ourTransaction.primaryDate;
    NSString *transactionDateString = [NSDateFormatter localizedStringFromDate:primaryDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    if ([ourTransaction.approximatePrimary boolValue])
        transactionDateString = [transactionDateString stringByAppendingString:@" (approx)"];
    // Get player name from retroID.
    NSString *playerFullName;
    if ([ourTransaction.playerIDOrName length]!=8) {
        playerFullName = ourTransaction.playerIDOrName; // field is full name.
    } else { // field is retro ID. Look up full name.
        playerFullName = [self fullNameForRetroID:ourTransaction.playerIDOrName];
    }
    if ([playerFullName isEqualToString:@" "] && [ourTransaction.type isEqualToString:@"T "] && [ourTransaction.info isEqualToString:@"$"]) {
        playerFullName = @"Cash Transfer";
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",transactionDateString,playerFullName];
    cell.detailTextLabel.text = [ourTransaction descriptionString];
    if ([ourTransaction relatedTransactionsCount]>1 && !_transactionID)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Transaction *thisTransaction = _transactions[indexPath.row];
    if ([segue.identifier isEqualToString:@"transactionToTransactions"]) {
        NSString *transactionID = thisTransaction.transactionID;
        [segue.destinationViewController setValue:_player forKey:@"player"];
        [segue.destinationViewController setValue:transactionID forKey:@"transactionID"];
    } else if ([segue.identifier isEqualToString:@"transactionToDifferentPlayer"]) {
        // Assume this is a player (retro) ID.
        NSFetchRequest *differentPlayerFetch = [NSFetchRequest fetchRequestWithEntityName:@"Master"];
        NSPredicate *differentPred = [NSPredicate predicateWithFormat:@"retroID == %@",thisTransaction.playerIDOrName];
        [differentPlayerFetch setPredicate:differentPred];
        NSError *error = nil;
        BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *oneRetroID = [[appDel managedObjectContext] executeFetchRequest:differentPlayerFetch error:&error];
        BQPlayer *differentPlayer = [[BQPlayer alloc] initWithPlayer:oneRetroID[0] teamSeason:nil];
        [segue.destinationViewController setValue:differentPlayer forKey:@"player"];
    }
}

//
// tableView didSelectRowAtIndexPath - Need to do this in code since
// there are three possible choices of segues:
// 1. if there are related transactions and we are not already in the
//    related transaction view, do recursive segue (transactionToTransactions).
// 2. otherwise if this is a different player, go to his PlayerYears (transactionToDifferentPlayer).
// 3. Else do nothing.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_transactions count] == 0) return;
    Transaction *thisTransaction = _transactions[indexPath.row];
    if ([thisTransaction relatedTransactionsCount]>1 && !_transactionID) {
        // This is the same condition which puts the > accessory on the cell.
        [self performSegueWithIdentifier:@"transactionToTransactions" sender:self];
    } else {
        // If a different player. This could be difficult to determine
        // because sometimes Master.retroID is missing. Weird database
        // mapping logic here.
        // Do definitive comparison first. If equal then leave.
        if ([_player.master.retroID isEqualToString:thisTransaction.playerIDOrName]) return;
        // Still a possibility that this is a different player.
        // Try just comparing last names.
        // If we don't have an id in the transaction, don't allow select.
        if ([thisTransaction.playerIDOrName length]!=8) return;
        if (_player.master.retroID && ![_player.master.retroID isEqualToString:@" "]) {
            // If valid master.retroID and it's different than this transaction, then allow select.
            [self performSegueWithIdentifier:@"transactionToDifferentPlayer" sender:self];
        } else {
            // player.master.retroID is not valid. Do name compare.
            // Get RetroID record for transaction guy.
            NSFetchRequest *playerCompare = [NSFetchRequest fetchRequestWithEntityName:@"RetroID"];
            NSPredicate *playerComparePred = [NSPredicate predicateWithFormat:@"id == %@",thisTransaction.playerIDOrName];
            [playerCompare setPredicate:playerComparePred];
            NSError *error = nil;
            NSArray *oneRetroID = [[[RetrosheetController sharedInstance] retrosheetManagedObjectContext] executeFetchRequest:playerCompare error:&error];
            RetroID *retroPlayer = oneRetroID[0];
            if (![_player.master.nameLast isEqualToString:retroPlayer.nameLast] || ![_player.master.nameLast isEqualToString:retroPlayer.nameLast]) {
                // OK let's assume this is a different player.
                [self performSegueWithIdentifier:@"transactionToDifferentPlayer" sender:self];
            }
        }
    }
}

#pragma Transaction lookups

/*
 type - one of the following
 A  - assigned from one team to another without compensation
 C  - conditional deal
 Cr - returned to original team after conditional deal
 D  - rule 5 draft pick
 Da - amateur draft pick
 Df - first year draft pick
 Dm - minor league draft pick
 Dn - selected in amateur draft but did not sign
 Dr - returned to original team after draft selection
 Ds - special draft pick
 Dv - amateur draft pick voided
 F  - free agent signing
 Fa - amateur free agent signing
 Fb - amateur free agent "bonus baby" signing under the 1953-57
 rule requiring player to stay on ML roster
 Fc - free agent compensation pick
 Fg - free agent granted
 Fo - free agent signing with first ML team
 Fv - free agent signing voided
 Hb  - went on the bereavement list
 Hbr - came off the bereavement list
 Hd  - declared ineligible
 Hdr - reinistated from the ineligible list
 Hf  - demoted to the minor league
 Hfr - promoted from the minor league
 Hh  - held out
 Hhr - ended hold out
 Hi  - went on the disabled list
 Hir - came off the disabled list
 Hm  - went into military service
 Hmr - returned from military service
 Hs  - suspended
 Hsr - reinstated after a suspension
 Hu  - unavailable but not on DL
 Hur - returned from being unavailable
 Hv  - voluntarity retired
 Hvr - unretired
 J  - jumped teams
 Jr - returned to original team after jumping
 L  - loaned to another team
 Lr - returned to original team after loan
 M  - obtained rights when entering into working agreement with
 minor league team
 Mr - rights returned when working agreement with minor league
 team ended
 P  - purchase
 Pr - returned to original team after purchase
 Pv - purchase voided
 R  - release
 T  - trade
 Tn - traded but refused to report
 Tp - added to trade (usually because one of the original
 players refused to report or retired)
 Tr - returned to original team after trade
 Tv - trade voided
 U  - unknown (could have been two separate transactions)
 Vg - player assigned to league control
 V  - player purchased or assigned to team from league
 W  - waiver pick
 Wf - first year waiver pick
 Wr - returned to original team after waiver pick
 Wv - waiver pick voided
 X  - expansion draft
 Xp - added as expansion pick at a later date
 Z  - voluntarily retired
 Zr - returned from voluntarily retired list
*/


@end

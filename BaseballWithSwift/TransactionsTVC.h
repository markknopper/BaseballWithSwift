//
//  TransactionsTVC.h
//  BaseballQuery
//
//  Created by Mark Knopper on 9/17/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "BQPlayer.h"

@interface TransactionsTVC : UITableViewController

@property (nonatomic, strong) BQPlayer *player;
@property (nonatomic, strong) NSNumber *year; // If zero do all years.
@property (nonatomic, strong) NSArray *transactions;
// If transactionID nonzero get all transactions for this ID.
// If zero, get all transactions for this player.
@property (nonatomic, strong) NSString *transactionID;

+(BOOL)anyTransactionsForPlayer:(BQPlayer *)player;

@end

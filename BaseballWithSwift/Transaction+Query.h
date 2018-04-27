//
//  Transaction+Transaction_Query.h
//  BaseballQuery
//
//  Created by Mark Knopper on 9/20/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "Transaction.h"

@interface Transaction (Query)

-(NSString *)descriptionString;
-(NSInteger)relatedTransactionsCount;
//-(NSArray *)relatedTransactions;

@end

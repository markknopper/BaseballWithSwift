//
//  InAppPurchaseObserver.m
//  BaseballQuery
//
//  Created by Mark Knopper on 3/4/13.
//  Copyright (c) 2013-2018 Bulbous Ventures LLC. All rights reserved.
//

/* Observe transactions, possibly from previous run of application where purchase
 was interrupted in progress. */

#import "InAppPurchaseObserver.h"
#import "BaseballQueryAppDelegate.h"
#import "ThisYear.h"

@implementation InAppPurchaseObserver

// Here from observing transaction on SKPaymentQueue defaultQueue.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                NSString *purchasedMessage = [NSString stringWithFormat:@"Purchase of %d Stats successful.",LATEST_DATA_YEAR];
                [self completeTransaction:transaction withMessage:purchasedMessage];
                break;
            }
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
            {
                NSString *previousPurchaseMessage = [NSString stringWithFormat:@"Previous purchase of %d Stats successful.",LATEST_DATA_YEAR];
                [self completeTransaction:transaction withMessage:previousPurchaseMessage];
            }
            default:
            { // here when "purchasing".
                break;
            }
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction withMessage:(NSString *)message
{
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%d Stats Purchase",LATEST_DATA_YEAR] message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [successAlert addAction:defaultAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:successAlert animated:YES completion:nil];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDel installLatestDatabase]; // Boom. (jgs doesn't like that word)
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark Restore

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    // 0 transactions means nothing to restore.
    if ([queue.transactions count]==0) {
        UIAlertController *failedAlert = [UIAlertController alertControllerWithTitle:@"Restore Failed" message:@"Sorry, no previous purchases could be restored" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [failedAlert addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:failedAlert animated:YES completion:nil];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    UIAlertController *failedAlert = [UIAlertController alertControllerWithTitle:@"Purchase Failed" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [failedAlert addAction:defaultAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:failedAlert animated:YES completion:nil];
}

// Helps advertise in-app purchase product on the App Store?
- (BOOL)paymentQueue:(SKPaymentQueue *)queue
shouldAddStorePayment:(SKPayment *)payment
          forProduct:(SKProduct *)product
{
        return TRUE;
}


@end

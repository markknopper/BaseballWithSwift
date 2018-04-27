//
//  InAppPurchaseController.m
//  BaseballQuery
//
//  Created by Mark Knopper on 3/4/13.
//  Copyright (c) 2013-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "InAppPurchaseController.h"
#import "BaseballQueryAppDelegate.h"
#import "ThisYear.h"

@implementation InAppPurchaseController

#define PRODUCT_URI @"com.bulbousventuresllc.BaseballStatistics."LATEST_DATA_YEAR_STRING"Stats"

// product name will be com.bulbousventuresllc.BaseballStatistics.20**Stats

// The simplest singleton I could find.
+(InAppPurchaseController *)sharedInstance
    {
        static InAppPurchaseController *this = nil;
        if (!this)
        this = [[InAppPurchaseController alloc] init];
        return this;
    }
    
-(id)init {
    if (self = [super init]) {
        self.user_requested_purchase = FALSE;
        [self getProductInfo]; // Get this as early as possible.
    }
    return self;
}

// Called from init (only).
-(void)getProductInfo {
    if (self.product == nil) {
        if ([SKPaymentQueue canMakePayments]) {
            // Example: product request at startup does not complete.
            // Then do another one when user clicks Buy button.
            // request response should figure out if the user is waiting
            // to actually do a buy or if it's just an advance request.
            // Is there any chance of this already being outstanding? Doesn't matter.
            SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_URI]];
            productRequest.delegate = self;
            [productRequest start]; //->productsRequest:didReceiveResponse
        }
    }
}

// Here from clicking buy button in AllTeams and AllPlayers (et al) controllers.
// View Controllers should pass 'self' so we can present our alert.
-(void)startPurchase:(UIViewController *)baseVC
{
    self.baseVC = baseVC; // Save this for future alert presenting.
    // Need to check again for canMakePayments because this time the user asked to buy something so here is where they get the bad news.
    if ([SKPaymentQueue canMakePayments])
    {
        /*
         // What if earlier product request didn't complete? Definitely do one more request when the user clicks Buy, in case things have improved such as network connectivity or even user updated credit card in iTunes store.
         */
        if (_product == nil) {
            //NSLog(@"startPurchase product=nil");
            SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_URI]];
            productRequest.delegate = self;
                self.user_requested_purchase = TRUE; // when response comes back do the actual buying (actually just the next step which is to present the question about the price.
            [productRequest start]; //->productsRequest:didReceiveResponse
            // didReceiveResponse will ask buying question at that time.
        } else {
            //NSLog(@"startPurchase product!=nil");
            // Ask right away since we have product info.
            [self askBuyingQuestion];
        }
    } else  {
        // Not allowed to make payments. Give bad news. I suppose we could have hidden the Buy button in this case but why not build up their desire to fix the problem and buy?
        UIAlertController *sorryAlert = [UIAlertController alertControllerWithTitle:@"Payments Disabled" message:@"Not authorized to make purchases." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [sorryAlert addAction:defaultAction];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:sorryAlert animated:YES completion:nil];
    }
}

-(void)askBuyingQuestion
    {
        // Ask user if they want to buy product for {localized} amount.
        // The individual view controllers just call this and never have to do it themselves, though how to get the self to present from?
        
        // Format the localized price using recommended localized price formatter.
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:_product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:_product.price];
        // Create an alert with aforementioned price.
        UIAlertController *buyNowAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%d Season",LATEST_DATA_YEAR] message:[NSString stringWithFormat:@"Would you like to buy the %d season for %@?",LATEST_DATA_YEAR, formattedString] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            SKPayment *payment = [SKPayment paymentWithProduct:_product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
        [buyNowAlert addAction:defaultAction];
        [buyNowAlert addAction:cancelAction];
        if (_baseVC == nil) return; // Well dang.
        [_baseVC presentViewController:buyNowAlert animated:YES completion:nil];
    }
    
// Here from Restore button in AboutController
-(void)restorePurchases
{
    // Do it the old school way. RefreshReceipt is really weird.
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

// SKProductsRequestDelegate method (From startPurchase->SKProductsRequest start,
// or from product request at init.
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    for (SKProduct *aProduct in response.products) { // Just look for our one product.
        if ([aProduct.productIdentifier isEqualToString:PRODUCT_URI]) {
            self.product = aProduct; // We have valid product info.
            // Check a buy requested flag to see if we should buy now
            if (_user_requested_purchase) {
                // This creates user dialog to confirm purchase request, including login prompt.
                [self askBuyingQuestion];
            }
            return; // Ignore any other type of product (eg. older years).
        }
    }
}

@end

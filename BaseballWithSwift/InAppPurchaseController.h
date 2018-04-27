//
//  InAppPurchaseController.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/4/13.
//  Copyright (c) 2013-2018 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppPurchaseController : NSObject <SKRequestDelegate, SKProductsRequestDelegate>

@property (nonatomic, strong) SKProduct *product; // validated product!
@property (nonatomic, assign) BOOL user_requested_purchase;
@property (nonatomic, strong) UIViewController *baseVC;

+(InAppPurchaseController *)sharedInstance;
-(void)startPurchase:(UIViewController *)baseVC;
-(void)restorePurchases;

@end

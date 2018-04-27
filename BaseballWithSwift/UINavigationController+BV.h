//
//  UINavigationController+BV.h
//  myAppDB
//
//  Created by Matthew Jones on 5/19/10.
//  Copyright 2010-2014 Bulbous Ventures. All rights reserved.
//

//#import <UIKit/UIKit.h>

@import UIKit;

@class UIViewController;

@interface UINavigationController (BV)

- (UIViewController *)backViewController;
- (UIViewController *)backViewControllerForViewController:(UIViewController *)viewController;

@end

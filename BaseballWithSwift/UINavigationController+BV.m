//
//  UINavigationController+BV.m
//  myAppDB
//
//  Created by Matthew Jones on 5/19/10.
//  Copyright 2010-2014 Bulbous Ventures. All rights reserved.
//

#import "UINavigationController+BV.h"


@implementation UINavigationController (BV)

- (UIViewController *)backViewController {
	NSArray *vcs = [self viewControllers];
	NSInteger back_index = [vcs count]-2;
	if (back_index >= 0) {
		return vcs[back_index];
	} else {
		return nil;
	}
}

//
//  Return the backViewController for a given viewController on the Nav stack.
//  If the viewController is not on the Nav stack, or if it is the root controller,
//  then return nil.
//
- (UIViewController *)backViewControllerForViewController:(UIViewController *)viewController {
	UIViewController *backViewController = nil;
	
	NSArray *vcs = [self viewControllers];
	NSInteger bvc_index = [vcs indexOfObject:viewController];
	if ((bvc_index != NSNotFound) && (bvc_index > 0)) {
		backViewController = vcs[(bvc_index-1)];
	}
	return backViewController;
}

@end

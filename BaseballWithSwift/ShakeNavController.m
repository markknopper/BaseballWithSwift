//
//  ShakeNavControllerViewController.m
//  BaseballWithSwift
//
//  Created by Mark Knopper on 2/28/13.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
// 
//

#import "ShakeNavController.h"
#import "AllTeams.h"

@implementation ShakeNavController

#pragma mark SHAKE!

//
// shakeMeUp - User shook iPhone. Pop all view controllers and go back to home screen and factory settings.
//
-(void)shakeMeUp
{
	// End rotated baseball card or web view if that's what is visible.
	[[self visibleViewController] dismissViewControllerAnimated:YES completion:NULL];
    self.shaking = YES;
	[self popToRootViewControllerAnimated:YES];
}

// UIViewController is subclass of UIResponder, so we get this event.
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        // User shook iPhone. Pop all view controllers and go back to home screen and factory settings.
        [self shakeMeUp];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    self.shaking = NO;
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

@end

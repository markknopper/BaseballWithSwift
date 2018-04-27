//
//  ShakeNavControllerViewController.h
//  BaseballQuery
//
//  Created by Mark Knopper on 2/28/13.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShakeNavController : UINavigationController

@property (assign) BOOL shaking;

-(void)shakeMeUp;

@end

//
//  main.m
//  BaseballQuery
//
//  Created by Matthew Jones on 4/20/10.
//  Copyright Bulbous Ventures LLC 2010-2016. All rights reserved.
//

@import UIKit;
#import "BaseballQueryAppDelegate.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        // specify application delegate class here! Storyboard won't do that (NIB would).
        int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([BaseballQueryAppDelegate class]));
        return retVal;
    }
}
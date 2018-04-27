//
//  NewBaseballCardViewController.h
//  BaseballQuery
//
//  Created by Mark Knopper on 12/6/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "BQPlayer.h"

@interface BaseballCardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    BOOL thisViewHasAppeared; // This is absolutely necessary.
}

@property (strong,nonatomic) NSDictionary *baseballCardDictionary;
@property (strong,nonatomic) BQPlayer *player;
@property (nonatomic, strong) NSString *originalTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *horizontalScroller;
@property (weak, nonatomic) IBOutlet UITableView *wideTableView;
@property (weak, nonatomic) IBOutlet UIView *scrollerContainer;

@end

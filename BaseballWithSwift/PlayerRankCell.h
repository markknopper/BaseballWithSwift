//
//  PlayerRankCell.h
//  
//
//  Created by Mark Knopper on 2/7/13.
//  Copyright 2013-2015 Bulbous Ventures LLC. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface PlayerRankCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *playerNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *rankLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UILabel *teamNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *statLabel;

@end

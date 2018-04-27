//
//  PlayerYearsController.h
//  Baseball_Stats_Core_Data
//
//  Created by Mark Knopper on 12/23/09.
//  Copyright 2009-2015 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
#import "BQPlayer.h"
#import "Master+Query.h"

@interface PlayerYearsController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>
{
    BOOL isShowingLandscapeView, thisViewHasAppeared, needToShowBaseballCardView;
}

@property (nonatomic, strong) NSString *originalTitle;
@property (nonatomic, strong) BQPlayer *player;
@property (nonatomic, strong) NSArray *yearsInOrder;
@property (nonatomic, strong) NSString *playerID;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webButton;

-(void)changeToPlayer:(BQPlayer *)aPlayer;

@end

//
//  RetroID.h
//  BaseballQuery
//
//  Created by Mark Knopper on 9/30/13.
//  Copyright (c) 2013-2015 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RetroID : NSManagedObject

@property (nonatomic, retain) NSString * nameFirst;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * nameLast;
@property (nonatomic, retain) NSDate * debut;

@end

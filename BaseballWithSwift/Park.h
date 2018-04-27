//
//  Park.h
//  BaseballQuery
//
//  Created by Mark Knopper on 6/15/11.
//  Copyright (c) 2011 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Park : NSManagedObject {
@private
}
@property (nonatomic) NSString * parkID;
@property (nonatomic) NSString * city;
@property (nonatomic) NSDate * start;
@property (nonatomic) NSString * aka;
@property (nonatomic) NSDate * end;
@property (nonatomic) NSString * league;
@property (nonatomic) NSString * notes;
@property (nonatomic) NSString * state;
@property (nonatomic) NSString * name;

@end

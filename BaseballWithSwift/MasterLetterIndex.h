//
//  MasterLetterIndex.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/5/14.
//  Copyright (c) 2014 Bulbous Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MasterLetterIndex : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * letter;

@end

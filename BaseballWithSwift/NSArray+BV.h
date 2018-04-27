//
//  NSArray+BV.h
//  Bulbous Ventures NSArray convenience extensions
//
//  Created by Matthew Jones on 4/14/10.
//  Copyright 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

@interface NSArray (BV)

-(NSArray *)sortedArrayUsingKey:(NSString *)ascendingSortKey;
-(NSArray *)sortedArrayUsingKey:(NSString *)sortKey ascending:(BOOL)ascending;
-(NSArray *)arrayUsingSelector:(SEL)selector;
- (NSInteger) binarySearchForObject:(id)object compareKey:(NSString *)compareKey ascending:(BOOL)its_ascending;
-(NSString *)displayStringForStat:(NSString *)statName;

@end

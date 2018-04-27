//
//  UIViewController+IndexLetters.h
//  BaseballQuery
//
//  Created by Mark Knopper on 10/8/10.
//  Copyright (c) 2010-2014 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

@interface UIViewController (IndexLetters) 
   
// displayList and indexLetters to be
// declared as instance variables in your UIViewController subclass.
// Categories can't define their own instance variables.
//
-(void)computeTableIndicesFromArrayUpdatingDisplayList:(NSArray *)ourArray withKeyPath:(NSString *)firstLetterKey;
-(NSDictionary *)computeTableIndicesFromArray:(NSArray *)ourArray withKeyPath:(NSString *)firstLetterKey;
-(void)computeTableIndicesFromYearArray:(NSArray *)ourArray withKeyPath:(NSString *)yearKey ascending:(BOOL)sort_order_ascending;
-(id)indexLettersObjectForIndexPath:(NSIndexPath *)indexPath;

@end

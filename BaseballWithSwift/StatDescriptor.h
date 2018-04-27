//
//  StatDescriptor.h
//  BaseballQuery
//
//  Created by Matthew Jones on 5/31/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//
//
//  Full description of a baseball stat in relation to the Model.
//  The StatDescriptor contains the key attribute that returns the
//  stat value in a sortable form, the label that would be used to accompany
//  the stat.
//
//  The stat selectors are usually gathered into collections so that a number
//  of stats can be displayed together with the appropriate labels.  The StatsDisplay
//  class does this and passes out the collections on demand.
//

#import "StatsDisplay.h"
#import "StatsDisplayFactory.h" // Maybe should be StatDescriptorFactory
#import "StatsDisplayStatType.h"

// Macros used in StatsDisplayFactory.m

#define MAKE_STAT_DESCRIPTOR_WITH_KEY(aKey) \
    ({ StatDescriptor *anSD =[[StatDescriptor alloc] init]; \
    anSD.key = aKey; \
    anSD; })

#define MAKE_STAT_DESCRIPTOR_WITH_LABEL(aLabel) \
    ({ StatDescriptor *anSD =[[StatDescriptor alloc] init]; \
    anSD.label = aLabel; \
    anSD; })

#define MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER(aKey,aLabel,low_is_better) \
    ({ StatDescriptor *anSD =[[StatDescriptor alloc] init]; \
    anSD.key = aKey; \
    anSD.label = aLabel; \
    anSD.ascending = low_is_better; \
    anSD; })

#define MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_LOWISBETTER_RANKING(aKey,aLabel,low_is_better,rankable) \
    ({ StatDescriptor *anSD =[[StatDescriptor alloc] init]; \
    anSD.key = aKey; \
    anSD.label = aLabel; \
    anSD.ascending = low_is_better; \
    anSD.isRankableSelectorName = rankable; \
    anSD; })

#define MAKE_STAT_DESCRIPTOR_WITH_KEY_LABEL_SEGUE(aKey,aLabel,aSegueName) \
    ({ StatDescriptor *anSD =[[StatDescriptor alloc] init]; \
    anSD.key = aKey; \
    anSD.label = aLabel; \
    anSD.segueName = aSegueName; \
    anSD; })

@interface StatDescriptor : NSObject

// Minimal stat descriptor just has label. Can have value too.
// Could use value for caching results! Or to say no need to compute.

// key:         db stat name. Hopefully consistent.
// label:       label to display
// value:       if known
// isRankableSelectorName: name of selector that can determine if a statObject qualifies for ranking on this stat
// isStatMissing: method to do error check for missing stats.
// segueName:   perform this on row select
// is_computed_method: Selector to call on stat source in order to get value.
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *value;
@property (assign) BOOL ascending;
@property (strong, nonatomic) NSString *isRankableSelectorName;
@property (assign, nonatomic) SEL isStatMissing;
@property (nonatomic,strong) NSString *segueName;
@property (assign) SEL is_computed_method;
/*
 // Also overload this object with some stuff for Leaders results (used in QueryResultsController):
 // minimumPredicateStringForLeaders: just what it says
 // postProcessingForLeaders: method to do advanced selection of leaders.

@property (strong, nonatomic) NSString *minimumPredicateStringForLeaders;
@property (assign, nonatomic) SEL postProcessingForLeaders;
*/

@end

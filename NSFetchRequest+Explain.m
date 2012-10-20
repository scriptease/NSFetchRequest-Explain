/*
 * Copyright 2012 Florian Agsteiner
 */


#import "NSFetchRequest+Explain.h"
#import "NSObject+Explain.h"

#import <CoreData/NSManagedObjectID.h>

#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSComparisonPredicate.h>
#import <Foundation/NSCompoundPredicate.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSExpression.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>

#import <objc/runtime.h>

/**
 *  Stores the result of a predicate
 */
@interface FAExplainResult : NSObject

/**
 *  Constructor
 */
+ (id) result;

/**
 *  Did the predicate match?
 */
@property(nonatomic,assign, getter = isMatch) BOOL match;

/**
 *  Aggegation: How many the predicates matched?
 */
@property(nonatomic,assign) BOOL numberOfMatches;

/**
 *  Description of the predicate?
 */
@property(nonatomic,copy) NSString* description;

/**
 *  Value the predicate was tested with or an error that accured
 */
@property(nonatomic,copy) NSString* value;

/**
 *  Create a deep copy of the object
 */
- (id)deepCopy;

/**
 *  modify the number of matches accordingly
 */
- (void) aggregateResult:(FAExplainResult*)result;

/**
 *  Print a description based on match, description and value
 */
- (NSString*)recursiveDescription;

/**
 *  Print a description based on the number of matches and description
 */
- (NSString*)recursiveAggregateDescription;

@end

/**
 *  Stores the result of a compound predicate
 */
@interface FAExplainCompountResult : FAExplainResult

/**
 *  The sub result for the subpredicates
 */
@property(nonatomic,copy) NSArray* subResults;

@end

@implementation FAExplainResult

+ (id) result{
    return [[[[self class] alloc] init] autorelease];
}

/**
 *  Beautification for the match
 */
- (NSString*) matchString{
    return self.match ? @"✔" : @"✘";
}

- (id)deepCopy{
    FAExplainResult* result = [[self class] result];
    result.match = self.match;
    result.numberOfMatches = self.numberOfMatches;
    result.description = self.description;

    return result;
}

- (void) aggregateResult:(FAExplainResult*)result{
    if (result.match) {
        self.numberOfMatches ++;
    }
}

- (NSString*)recursiveDescription{
    NSString* description = [self recursiveTreeDescriptionWithRecursiveBlockReturningChildren:^(FAExplainResult* node, NSArray** children) {
        NSString* description =[NSString stringWithFormat:@"%@ %@",[node matchString],[node description]];

        if (node.value != nil) {
            description = [description stringByAppendingFormat:@": %@",node.value];
        }

        if ([node isKindOfClass:[FAExplainCompountResult class]]) {
            *children = [(FAExplainCompountResult*)node subResults];
        }

        return description;
    }];
    return description;
}

- (NSString*)recursiveAggregateDescription{
    NSString* description = [self recursiveTreeDescriptionWithRecursiveBlockReturningChildren:^(FAExplainResult* node, NSArray** children) {
               NSString* description =[NSString stringWithFormat:@"%d %@",[node numberOfMatches],[node description]];

               if ([node isKindOfClass:[FAExplainCompountResult class]]) {
                   *children = [(FAExplainCompountResult*)node subResults];
               }

               return description;
           }];
    return description;
}

@end

@implementation FAExplainCompountResult

- (id)deepCopy{
    FAExplainCompountResult* result = [super deepCopy];
    NSMutableArray* subresults = [NSMutableArray arrayWithCapacity:[self.subResults count]];

    for (FAExplainResult* subresult in self.subResults) {
        [subresults addObject:[subresult deepCopy]];
    }

    result.subResults = subresults;

    return result;
}


- (void) aggregateResult:(FAExplainCompountResult*)result{
    [super aggregateResult:result];

    for (NSUInteger i =0; i< MIN([self.subResults count], [result.subResults count]); i++) {
        FAExplainResult* subresult = [self.subResults objectAtIndex:i];
        [subresult aggregateResult:[result.subResults objectAtIndex:i]];
    }
}

@end

@implementation NSPredicate (Explain)

- (NSString*)explainDescription{
    NSString* description = [self description];

    NSRange lineBreak = [description rangeOfString:@"\n"];
    if (lineBreak.location != NSNotFound) {
        description = [[description substringToIndex:lineBreak.location] stringByAppendingString:@"..."];
    }
    else if ([description length] >200) {
        description = [[description substringFromIndex:200] stringByAppendingString:@"..."];
    }
    
    return description;
}

/**
 *  Evaluate a predicate recursive and return a explain result
 */
- (FAExplainResult*)explainResultWithObject:(id)object substitutionVariables:(NSDictionary *)bindings context:(NSManagedObjectContext*)context{
    FAExplainResult* result = [FAExplainResult result];
    result.description = [self explainDescription];

    if (object != nil) {
        @try {
            if ([object isKindOfClass:[NSManagedObjectID class]] && context != nil) {
                object = [context objectWithID:object];
            }
            result.match = [self evaluateWithObject:object substitutionVariables:nil];
        }
        @catch (NSException *exception) {
            result.match = NO;
            result.value = [exception reason];
        }
    }

    return result;
}

/**
 *  Creates a description to explain a collection
 */
+ (NSString*) explainWithPredicate:(NSPredicate*)predicate collection:(id<NSFastEnumeration>)collection context:(NSManagedObjectContext*)context aggregateOnly:(BOOL)aggregateOnly{
    NSString* explain = @"NO PREDICATE";
    
    if (predicate != nil) {
        NSMutableString* mutableDescription = [NSMutableString string];

        NSUInteger count = 0;

        FAExplainResult* aggregate = nil;
        
        for (id object in collection) {

            FAExplainResult* result = [predicate explainResultWithObject:object substitutionVariables:nil context:context];

            if (aggregate == nil) {
                aggregate = [result deepCopy];
            }
            else{
                [aggregate aggregateResult:result];
            }

            if (!aggregateOnly) {
                [mutableDescription appendFormat:@"%d. %@ %@\n",count, [object explainDescription], [result matchString]];
                [mutableDescription appendFormat:@"\t%@\n",[[result recursiveDescription] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
            }

            count++;
        }

        if (aggregate == nil) {
            explain = @"NO OBJECTS FOUND";
        }
        else{
            [mutableDescription appendString:@"Aggregate:\n"];
            [mutableDescription appendString:[aggregate recursiveAggregateDescription]];

            explain = mutableDescription;
        }
    }

    return explain;
}

/**
 *  Creates a description to explain a object
 */
+ (NSString*) explainWithPredicate:(NSPredicate*)predicate object:(id)object{
    NSString* explain = @"NO PREDICATE";
    
    if (predicate != nil) {
        explain = [predicate explainWithObject:object substitutionVariables:nil];
    }

    return explain;
}

/**
 *  Creates a description to explain a predicate
 */
+ (NSString*) explainWithPredicate:(NSPredicate*)predicate{
    return [self explainWithPredicate:predicate object:nil];
}

- (NSString*) explainWithObject:(id)object substitutionVariables:(NSDictionary *)bindings{
    NSString* explain = nil;

    if ([object conformsToProtocol:@protocol(NSFastEnumeration)]) {
        explain = [NSPredicate explainWithPredicate:self collection:object context:nil aggregateOnly:NO];
    }
    else{
        FAExplainResult* result = [self explainResultWithObject:object substitutionVariables:nil context:nil];
        explain = [result recursiveDescription];
    }

    return explain;
}

-(NSString *)explainWithObject:(id)object{
    return [self explainWithObject:object substitutionVariables:nil];
}

-(NSString *)explain{
    return [self explainWithObject:nil];
}

@end

@implementation NSCompoundPredicate (Explain)

- (NSString*) explainDescription{
    NSString* description = nil;

    switch (self.compoundPredicateType) {
        case NSNotPredicateType:
        {
            description = @"NOT";
            break;
        }
        case NSAndPredicateType:
        {
            description = @"AND";
            break;
        }
        case NSOrPredicateType:
        {
            description = @"OR";
            break;
        }

        default:
            break;
    }

    return description;
}

- (FAExplainCompountResult*)explainResultWithObject:(id)object substitutionVariables:(NSDictionary *)bindings context:(NSManagedObjectContext*)context{
    BOOL allMatch = YES;
    BOOL anyMatch = NO;
    NSMutableArray* results = [NSMutableArray arrayWithCapacity:[self.subpredicates count]];
    for (NSPredicate* predicate in self.subpredicates) {
        FAExplainResult* result = [predicate explainResultWithObject:object substitutionVariables:bindings context:context];
        [results addObject:result];

        allMatch = allMatch && result.match;
        anyMatch = anyMatch || result.match;
    }

    BOOL match = NO;
    NSString* description = [self explainDescription];

    switch (self.compoundPredicateType) {
        case NSNotPredicateType:
        {
            match = !allMatch;
            break;
        }
        case NSAndPredicateType:
        {
            match = allMatch;
            break;
        }
        case NSOrPredicateType:
        {
            match = anyMatch;
            break;
        }

        default:
            break;
    }

    FAExplainCompountResult* result = [FAExplainCompountResult result];
    result.match = match;
    result.description = description;
    result.subResults = results;

    return result;
}

@end



@implementation NSComparisonPredicate (Explain)

- (NSString*)explainDescription{
    NSString* description = nil;

    if (self.predicateOperatorType == NSEqualToPredicateOperatorType || self.predicateOperatorType == NSNotEqualToPredicateOperatorType) {
        NSMutableString* mutableDescription = nil;
        
        if (self.comparisonPredicateModifier == NSAllPredicateModifier) {
            mutableDescription = [NSMutableString stringWithString:@"ALL "];
        }
        else if (self.comparisonPredicateModifier == NSAnyPredicateModifier) {
            mutableDescription = [NSMutableString stringWithString:@"ANY "];
        }
        else{
            mutableDescription = [NSMutableString string];
        }

        [mutableDescription appendString:[self.leftExpression explainDescription]];

        if (self.predicateOperatorType == NSEqualToPredicateOperatorType){
            [mutableDescription appendString:@" == "];
        }
        else if(self.predicateOperatorType == NSNotEqualToPredicateOperatorType) {
            [mutableDescription appendString:@" != "];
        }
        else{
            @throw [NSException exceptionWithName:@"This should never happen" reason:nil userInfo:nil];
        }

        [mutableDescription appendString:[self.rightExpression explainDescription]];
        
        description = mutableDescription;
    }
    else{
        description = [self description];
    }

    NSRange lineBreak = [description rangeOfString:@"\n"];
    if (lineBreak.location != NSNotFound) {
        description = [[description substringToIndex:lineBreak.location] stringByAppendingString:@"..."];
    }
    else if ([description length] >200) {
        description = [[description substringFromIndex:200] stringByAppendingString:@"..."];
    }

    return description;
}

- (FAExplainResult*)explainResultWithObject:(id)object substitutionVariables:(NSDictionary *)bindings context:(NSManagedObjectContext*)context{
    FAExplainResult* result = [FAExplainResult result];
    result.description = [self explainDescription];

    if (object != nil) {
        @try {
            if ([object isKindOfClass:[NSManagedObjectID class]] && context != nil) {
                object = [context objectWithID:object];
            }
            result.match = [self evaluateWithObject:object substitutionVariables:nil];

            if (self.leftExpression.expressionType == NSKeyPathExpressionType) {
                NSString* keyPath = self.leftExpression.keyPath;
                result.value = [[object valueForKeyPath:keyPath] explainDescription];
            }
        }
        @catch (NSException *exception) {
            result.match = NO;
            result.value = [exception reason];
        }
    }

    return result;
}

@end

@implementation NSFetchRequest (Explain)

- (NSString*) explainWithObject:(id)object{
    return [NSPredicate explainWithPredicate:self.predicate object:object];
}

- (NSString*) explainWithResult:(NSArray*)result aggregateOnly:(BOOL)aggregateOnly{
    return [NSPredicate explainWithPredicate:self.predicate collection:result context:nil aggregateOnly:aggregateOnly];
}

- (NSString *)explainWithResult:(NSArray *)result{
    return [self explainWithResult:result aggregateOnly:NO];
}

-(NSString *)explain{
    return [NSPredicate explainWithPredicate:self.predicate];
}

@end

@implementation NSManagedObjectContext (Explain)

- (NSFetchRequest*)explainFetchRequestForRequest:(NSFetchRequest*)request ignorePredicate:(BOOL)ignorePredicate fetchLimit:(NSUInteger)fetchLimit{
    NSFetchRequest* fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:request.entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];

    if (fetchLimit == 0) {
        fetchLimit = [[NSUserDefaults standardUserDefaults] integerForKey:@"ExplainFetchRequestsLimit"];
    }
    if (fetchLimit < 100) {
        fetchLimit = 100;
    }
    [fetchRequest setFetchLimit:fetchLimit];

    if (!ignorePredicate) {
        [fetchRequest setPredicate:request.predicate];
    }

    return fetchRequest;
}

- (NSString*) explainFetchRequest:(NSFetchRequest*)request showIgnored:(BOOL)showIgnored fetchLimit:(NSUInteger)fetchLimit aggregateOnly:(BOOL)aggregateOnly{
    NSArray* result = nil;

    if (request.predicate != nil) {
        NSFetchRequest* explainRequest = [self explainFetchRequestForRequest:request ignorePredicate:showIgnored fetchLimit:fetchLimit];

        result = [self executeFetchRequest:explainRequest error:NULL];
    }
    return [NSPredicate explainWithPredicate:request.predicate collection:result context:self aggregateOnly:NO];
}

- (NSString*) explainFetchRequest:(NSFetchRequest*)request showIgnored:(BOOL)showIgnored{
    return [self explainFetchRequest:request showIgnored:showIgnored fetchLimit:0 aggregateOnly:NO];
}


-(NSString *)explainFetchRequest:(NSFetchRequest *)request{
    return [self explainFetchRequest:request showIgnored:NO fetchLimit:0 aggregateOnly:NO];
}

+ (void) load {
    @autoreleasepool{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ExplainFetchRequests"]) {
            Method old = class_getInstanceMethod([self class], @selector(executeFetchRequest:error:));
            Method new = class_getInstanceMethod([self class], @selector(executeFetchRequestAndExplain:error:));

            method_exchangeImplementations(old,new);
        }
    };
}

-(NSArray *)executeFetchRequestAndExplain:(NSFetchRequest *)request error:(NSError **)error{
    NSArray* result = nil;

    if (request.predicate != nil) {
        NSFetchRequest* explainRequest = [self explainFetchRequestForRequest:request ignorePredicate:YES fetchLimit:0];
        result = [self executeFetchRequestAndExplain:explainRequest error:NULL];

        BOOL aggregateOnly = [[NSUserDefaults standardUserDefaults] boolForKey:@"ExplainFetchRequestsAggregateOnly"];

        NSLog(@"%@",[result explainWithPredicate:request.predicate aggregateOnly:aggregateOnly]);
    }

    result = [self executeFetchRequestAndExplain:request error:error];
    return result;
}

@end

@implementation NSArray (Explain)

- (NSString*) explainWithPredicate:(NSPredicate*)predicate aggregateOnly:(BOOL)aggregateOnly{
    return [NSPredicate explainWithPredicate:predicate collection:self context:nil aggregateOnly:aggregateOnly];
}

-(NSString *)explainWithPredicate:(NSPredicate *)predicate{
    return [self explainWithPredicate:predicate aggregateOnly:NO];
}

@end

@implementation NSSet (Explain)

- (NSString*) explainWithPredicate:(NSPredicate*)predicate aggregateOnly:(BOOL)aggregateOnly{
    return [NSPredicate explainWithPredicate:predicate collection:self context:nil aggregateOnly:aggregateOnly];
}

-(NSString *)explainWithPredicate:(NSPredicate *)predicate{
    return [self explainWithPredicate:predicate aggregateOnly:NO];
}

@end


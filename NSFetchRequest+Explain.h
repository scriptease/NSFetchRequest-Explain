/*
 * Copyright 2012 Florian Agsteiner
 */


#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSFetchRequest.h>
#import <Foundation/NSPredicate.h>

@interface NSPredicate (Explain)

/**
 * Creates a explain description by applying the predicate to the object.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * If the predicate contains an error or keypath it will show it to easily detect mistakes or false positives.
 *
 * @param object The object to evalutate
 * @param bindings The mapping of substitution variables or nil
 */
- (NSString*) explainWithObject:(id)object substitutionVariables:(NSDictionary *)bindings;

/**
 * Creates a explain description by applying the predicate to the object.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * If the predicate contains an error or keypath it will show it to easily detect mistakes or false positives.
 *
 * @param object The object to evalutate
 */
- (NSString*) explainWithObject:(id)object;

/**
 * Creates a explain description based on the predicate.
 * It doesn't evaluates the predicate it just prints a formated description.
 */
- (NSString*) explain;

@end

@interface NSFetchRequest (Explain)

/**
 * Creates a explain description by applying the predicate of the request to the result array.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 * You can avoid the output of every element and only show the summary by setting aggregateOnly to YES.
 *
 * @param result The array of elements to evalutate
 * @param aggregateOnly Set to YES to only display a aggregation of all evaluations
 */
- (NSString*) explainWithResult:(NSArray*)result aggregateOnly:(BOOL)aggregateOnly;

/**
 * Creates a explain description by applying the predicate of the request to the result array.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 *
 * @param result The array of elements to evalutate
 */
- (NSString*) explainWithResult:(NSArray*)result;

/**
 * Creates a explain description by applying the predicate of the fetch request to the object.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * If the predicate contains an error or keypath it will show it to easily detect mistakes or false positives.
 *
 * @param object The object to evalutate
 */
- (NSString*) explainWithObject:(id)object;

/**
 * Creates a explain description based on the predicate of the fetch request.
 * It doesn't evaluates the predicate it just prints a formated description.
 */
- (NSString*) explain;

@end

@interface NSManagedObjectContext (Explain)

/**
 * Creates a explain description by applying the predicate to the result of the fetch request.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 * You can avoid the output of every element and only show the summary by setting aggregateOnly to YES.
 *
 * @param request The fetchrequest which predicate and result to evalutate
 * @param showIgnored Ignore the predicate when performing the fetchrequest to identify false positives
 * @param fetchLimit You can limit the number of elements fetched (default: 100)
 * @param aggregateOnly Set to YES to only display a aggregation of all evaluations
 */
- (NSString*) explainFetchRequest:(NSFetchRequest*)request showIgnored:(BOOL)showIgnored fetchLimit:(NSUInteger)fetchlimit  aggregateOnly:(BOOL)aggregateOnly;

/**
 * Creates a explain description by applying the predicate to the result of the fetch request.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 *
 * @param request The fetchrequest which predicate and result to evalutate
 * @param showIgnored Ignore the predicate when performing the fetchrequest to identify false positives
 */
- (NSString*) explainFetchRequest:(NSFetchRequest*)request showIgnored:(BOOL)showIgnored;

/**
 * Creates a explain description by applying the predicate to the result of the fetch request.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 *
 * @param request The fetchrequest which predicate and result to evalutate
 */
- (NSString*) explainFetchRequest:(NSFetchRequest*)request;

@end

@interface NSArray (Explain)

/**
 * Creates a explain description by applying the predicate to all elements of the array.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 * You can avoid the output of every element and only show the summary by setting aggregateOnly to YES.
 *
 * @param predicate The predicate to evalutate
 * @param aggregateOnly Set to YES to only display a aggregation of all evaluations
 */
- (NSString*) explainWithPredicate:(NSPredicate*)predicate aggregateOnly:(BOOL)aggregateOnly;

/**
 * Creates a explain description by applying the predicate to all elements of the array.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 *
 * @param predicate The predicate to evalutate
 */
- (NSString*) explainWithPredicate:(NSPredicate*)predicate;

@end

@interface NSSet (Explain)

/**
 * Creates a explain description by applying the predicate to all elements of the set.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 * You can avoid the output of every element and only show the summary by setting aggregateOnly to YES.
 *
 * @param predicate The predicate to evalutate
 * @param aggregateOnly Set to YES to only display a aggregation of all evaluations
 */
- (NSString*) explainWithPredicate:(NSPredicate*)predicate aggregateOnly:(BOOL)aggregateOnly;

/**
 * Creates a explain description by applying the predicate to all elements of the set.
 * It evaluates the predicate and prints out the recursive path where the predicate fails or matches.
 * 
 * The method will print a explaination for each element and a summary at the end.
 *
 * @param predicate The predicate to evalutate
 */
- (NSString*) explainWithPredicate:(NSPredicate*)predicate;

@end


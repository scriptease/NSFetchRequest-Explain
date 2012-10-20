/*
 * Copyright 2012 Florian Agsteiner
 */

#import "NSObject+Explain.h"

#import <Foundation/NSExpression.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSNull.h>

#import <CoreData/NSManagedObject.h>
#import <CoreData/NSManagedObjectID.h>

/**
 *  The non ascii version looks nicer but may be not supported depending on where you want to use it.
 */
#define FAExplainASCIIOnly 0

@implementation NSObject (Explain)

- (NSString*)explainDescription{
    return [NSString stringWithFormat: @"%@ <%p>", (id)[self class], (void*)self];
}

+ (void)performRecursiveTreeDescriptionWithNode:(id)node output:(NSMutableString*)output prefix:(NSString*)prefix isLast:(BOOL)isLast
                recursiveBlockReturningChildren:(NSString* (^)(id node,  NSArray** children)) recursiveBlock{
    NSArray* children = nil;

    NSString* description = recursiveBlock(node,&children);

#if FAExplainASCIIOnly
    [output appendFormat:@"%@%@%@\n",prefix, @"+-- ",description];
#else
    [output appendFormat:@"%@%@%@\n",prefix, (isLast ? @"└── " : @"├── "),description];
#endif

    if ([children conformsToProtocol:@protocol(NSFastEnumeration)]) {
        if ([children count] > 0) {
#if FAExplainASCIIOnly
            prefix = [prefix stringByAppendingString:(isLast ? @"    " : @"|   ")];
#else
            prefix = [prefix stringByAppendingString:(isLast ? @"    " : @"│   ")];
#endif

            NSUInteger index = 0;
            NSUInteger last = [children count] -1;

            for (id child in children) {
                BOOL isLast = (index == last);
                [self performRecursiveTreeDescriptionWithNode:child output:output prefix:prefix isLast:isLast recursiveBlockReturningChildren:recursiveBlock];
                
                index++;
            }
        }
    }
    else if(children != nil){
        prefix = [prefix stringByAppendingString:(isLast ? @"    " : @"│   ")];
        [self performRecursiveTreeDescriptionWithNode:children output:output prefix:prefix isLast:YES recursiveBlockReturningChildren:recursiveBlock];
    }
}

+ (NSString*)recursiveTreeDescriptionWithRoot:(id)root recursiveBlockReturningChildren:(NSString* (^)(id node,  NSArray** children)) recursiveBlock{
    NSMutableString* description = [NSMutableString stringWithCapacity:1000];
    [self performRecursiveTreeDescriptionWithNode:root output:description prefix:@"" isLast:YES recursiveBlockReturningChildren:recursiveBlock];

    return description;
}

+ (NSString*)recursiveTreeDescriptionWithRoot:(id)root descriptionSelector:(SEL)descriptionSelector recursiveChildrenSelector:(SEL)recursiveChildrenSelector{
    return [self recursiveTreeDescriptionWithRoot:root recursiveBlockReturningChildren:^(id node, NSArray **children) {
        id description = nil;

        if ([node respondsToSelector:descriptionSelector]) {
            description = [node performSelector:descriptionSelector];

            if (description == nil){
                description = [node description];
            }
        }
        else{
            description = [node description];
        }
        
        if ([node respondsToSelector:recursiveChildrenSelector]) {
            *children = [node performSelector:recursiveChildrenSelector];
        }

        return description;
    }];
}

- (NSString*)recursiveTreeDescriptionWithRecursiveBlockReturningChildren:(NSString* (^)(id node,  NSArray** children)) recursiveBlock{
    NSMutableString* description = [NSMutableString stringWithCapacity:1000];
    [[self class] performRecursiveTreeDescriptionWithNode:self output:description prefix:@"" isLast:YES recursiveBlockReturningChildren:recursiveBlock];

    return description;
}

- (NSString*)recursiveTreeDescriptionWithDescriptionSelector:(SEL)descriptionSelector recursiveChildrenSelector:(SEL)recursiveChildrenSelector{
	return [[self class] recursiveTreeDescriptionWithRoot:self descriptionSelector:descriptionSelector recursiveChildrenSelector:recursiveChildrenSelector];
}

@end

@implementation NSDate (Explain)

- (NSString*)explainDescription{
    return [self description];
}

@end

@implementation NSString (Explain)

- (NSString*)explainDescription{
    return [self description];
}

@end

@implementation NSValue (Explain)

- (NSString*)explainDescription{
    return [self description];
}

@end

@implementation NSNumber (Explain)

- (NSString*)explainDescription{
    return [self description];
}

@end

@implementation NSNull (Explain)

- (NSString*)explainDescription{
    return [self description];
}

@end

@implementation NSManagedObjectID (Explain)

- (NSString*)explainDescription{
    return [self description];
}

@end

@implementation NSManagedObject (Explain)

- (NSString*)explainDescription{
    return [NSString stringWithFormat:@"%@ <%p> %@", (id)[self class], (void*)self, [[self objectID] description]];;
}

@end

@implementation NSExpression (Explain)

- (NSString*)explainDescription{
    NSString* description = nil;

    if (self.expressionType == NSConstantValueExpressionType) {
        id value = [self constantValue];
        description = (value == nil)? @"nil" : [value explainDescription];
    }
    else{
        description = [self description];
    }

    return description;
}

@end

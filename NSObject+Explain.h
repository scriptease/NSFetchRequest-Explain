/*
 * Copyright 2012 Florian Agsteiner
 */

#import <Foundation/NSObject.h>

@class NSArray;

/**
 *  Used by NSFetchRequest+Explain for pretty printing
 */
@interface NSObject (Explain)

/**
 *  Return a short object description (without newlines)
 *
 *  @return The description
 */
- (NSString*) explainDescription;

/**
 *  Creates a tree description by asking for a description of each node and a list of children.
 *
 *  The children can be a list of objects, an object or nil, the algorithm will do a depth first description.
 *  Set the children to nil to terminate a subtree, it is also the default value. 
 *
 *  @param root The root object to start the recursion with (e.g. a UIWindow)
 *  @param @recursiveBlock A block that returns a description for the given node and a list of childen (e.g. the subviews)
 *  @return The description                       
 */
+ (NSString*)recursiveTreeDescriptionWithRoot:(id)root recursiveBlockReturningChildren:(NSString* (^)(id node,  NSArray** children)) recursiveBlock;

/**
 *  Creates a tree description by asking for a description of each node and a list of children.
 *
 *  It uses selectors to be able to use this method in the debugger.
 *  A few examples you can try:
 *
 *  1) Create a recursive view description
 *     po [NSObject recursiveTreeDescriptionWithRoot:(id)[UIWindow keyWindow] descriptionSelector:@selector(description) recursiveChildrenSelector:@selector(subviews)]
 *
 *  2) Create a recursive view description and show the controllers when possible (uses private api but who cares in the dubugger ;-))
 *     po [NSObject recursiveTreeDescriptionWithRoot:(id)[UIWindow keyWindow] descriptionSelector:@selector(_viewDelegate) recursiveChildrenSelector:@selector(subviews)]
 *
 *  3) Create a description of the responder chain of a given pointer
 *     po [NSObject recursiveTreeDescriptionWithRoot:(id)0xdeadbeef descriptionSelector:@selector(description) recursiveChildrenSelector:@selector(nextResponder)]
 *  
 *  @param root The root object to start the recursion with (e.g. a UIWindow)
 *  @param descriptionSelector The selector to return the string (e.g. @selector(description))
 *  @param recursiveChildrenSelector The selector to return the children, a list, single object, or nil (e.g. @selector(description))
 */
+ (NSString*)recursiveTreeDescriptionWithRoot:(id)root descriptionSelector:(SEL)descriptionSelector recursiveChildrenSelector:(SEL)recursiveChildrenSelector;

/**
 *  Creates a tree description by asking for a description of each node and a list of children, it will start with the current object.
 *
 *  The children can be a list of objects, an object or nil, the algorithm will do a depth first description.
 *  Set the children to nil to terminate a subtree, it is also the default value. 
 *
 *  @param @recursiveBlock A block that returns a description for the given node and a list of childen (e.g. the subviews)
 *  @return The description
 */
- (NSString*)recursiveTreeDescriptionWithRecursiveBlockReturningChildren:(NSString* (^)(id node,  NSArray** children)) recursiveBlock;

/**
 *  Creates a tree description by asking for a description of each node and a list of children, it will start with the current object.
 *
 *  It uses selectors to be able to use this method in the debugger.
 *  @see recursiveTreeDescriptionWithRoot:descriptionSelector:recursiveChildrenSelector:
 *  
 *  @param descriptionSelector The selector to return the string (e.g. @selector(description))
 *  @param recursiveChildrenSelector The selector to return the children, a list, single object, or nil (e.g. @selector(description))
 */
- (NSString*)recursiveTreeDescriptionWithDescriptionSelector:(SEL)descriptionSelector recursiveChildrenSelector:(SEL)recursiveChildrenSelector;

@end

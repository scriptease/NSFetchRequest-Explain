NSFetchRequest Superpowers
==========================

NSFetchRequest+Explain allows to debug NSFetchRequests and NSPredicates in visual way.

Featurelist:
------------

- Treelike description with pretty printing  
- Easy to use (just call explainXY on any result or object you like)
- Easy to find problems
   - Can be used to identify objects not found by the fetchrequest
   - Find hot spots (parts of the predicate that create the most misses)
   - just better visualisation as the default description
   - Shows actual values not just miss or match
- Find errors in the predicate (e.g. misstyped properties)
- Easy debug options with commandline arguments


How to use it:
--------------

a) Call explain on any object you like
--------------------------------------

- [NSPredicate explainWithObject:]
- [NSPredicate explain]

- [NSFetchRequest explainWithResult:]
- [NSFetchRequest explainWithObject:]
- [NSFetchRequest explain]

- [NSManagedObjectContext explainFetchRequest: showIgnored:]
- [NSManagedObjectContext explainFetchRequest:]

- [NSArray explainWithPredicate:]
- [NSSet explainWithPredicate:]

b) Use commandline options
--------------------------

![Commandline](https://raw.github.com/scriptease/NSFetchRequest-Explain/master/FetchRequestSettings.png)

-ExplainFetchRequests YES

This will enable a method swizzling and print a description for every fetchrequest executed.

-ExplainFetchRequestsAggregateOnly YES

Only show aggregation not every element of the fetch result

-ExplainFetchRequestsFetchLimit 100

Only explain the number of objects (default: 100)

How does it look?
-----------------

![Aggregation](https://raw.github.com/scriptease/NSFetchRequest-Explain/master/Aggregate.png)

![Deep Nesting](https://raw.github.com/scriptease/NSFetchRequest-Explain/master/DeepNesting.png)


How do i use the awesome tree printing?
---------------------------------------

Look in NSObject+Explain.h it's very easy and there are some examples on how to use it for other purposes.



I hope you enjoy it

Florian Agsteiner 
Twitter: @_dvplr 

//  Fit
//
//  Created by Chelsea Smith on 3/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

@import HealthKit;

@interface HKHealthStore (AAPLExtensions)

// Fetches the single most recent quantity of the specified type.
- (void)aapl_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion;

@end

//  Fit
//
//  Created by Chelsea Smith on 3/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "AAPLFoodItem.h"

@interface AAPLFoodItem ()

@property (nonatomic, readwrite) double joules;
@property (nonatomic, readwrite, copy) NSString *name;

@end

@implementation AAPLFoodItem

+ (instancetype)foodItemWithName:(NSString *)name joules:(double)joules {
    AAPLFoodItem *foodItem = [[self alloc] init];
    
    foodItem.name = name;
    foodItem.joules = joules;

    return foodItem;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[AAPLFoodItem class]]) {
        return [object joules] == self.joules && [self.name isEqualToString:[object name]];
    }
    
    return NO;
}

- (NSString *)description {
    return [@{
        @"name": self.name,
        @"joules": @(self.joules)
    } description];
}

@end

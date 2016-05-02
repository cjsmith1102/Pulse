//
//  WorkoutDataSource.h
//  Fit
//
//  Created by William Stowers on 5/2/16.
//  Copyright © 2016 Apple. All rights reserved.
//
@import Foundation;
@import UIKit;
@import HealthKit;
@protocol WorkoutDataSourceDelegate <NSObject>
-(void)workoutsListNeedRefreshing;
@end
@interface WorkoutDataSource : NSObject <UITableViewDataSource>
#pragma mark - Class Properties
//@property(nonatomic, retain) NSObject<FriendsListSourceDelegate>* delegate;
@property (nonatomic) HKHealthStore *healthstore;
@property (atomic)id<WorkoutDataSourceDelegate>delegate;
#pragma mark - Instance Initializer
//- (instancetype)initWithDelegate:(NSObject<FriendsListSourceDelegate>*)aDelegate;
-(instancetype)initWithHealthStore:(HKHealthStore*)store;
-(instancetype)initWithHealthStore:(HKHealthStore *)store withDelegate:(id<WorkoutDataSourceDelegate>)delegate;

- (HKWorkout*)getWorkoutAtIndexPath:(NSIndexPath*)indexPath;
#pragma mark - Update Methods
- (void)fetchLatestData;
@end

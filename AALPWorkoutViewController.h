//
//  AALPWorkoutViewController.h
//  Fit
//
//  Created by Chelsea Smith on 3/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

@import UIKit;
@import HealthKit;
#import "WorkoutDataSource.h"
@interface AALPWorkoutViewController : UITableViewController<UITableViewDelegate,WorkoutDataSourceDelegate>

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic,retain) WorkoutDataSource* workoutSource;

@end

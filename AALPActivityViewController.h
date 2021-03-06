//
//  AALPActivityViewController.h
//  Fit
//
//  Created by Chelsea Smithon 3/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

@import UIKit;
@import HealthKit;

@interface AALPActivityViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
- (IBAction)startWorkout:(id)sender;

@property (nonatomic) BOOL started;
@property (nonatomic) NSUInteger minutes;
@property (nonatomic) NSUInteger seconds;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic) NSUInteger calories;
@property (nonatomic) double heartrate;
@property (nonatomic) NSTimer *workoutTimer;
@property (nonatomic) NSTimer *heartRateTimer;
@property (nonatomic) NSTimer *calorieTimer;
@property (nonatomic, retain) HKObserverQuery *heartRateQuery;
@property (nonatomic, retain) NSDate *lastHeartRateCheck;
@property (nonatomic, retain) NSDate *lastCalorieCheck;


@property (nonatomic) HKHealthStore *healthStore;

@end

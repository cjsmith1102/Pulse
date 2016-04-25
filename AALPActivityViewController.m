//
//  AALPActivityViewController.m
//  Fit
//
//  Created by Chelsea Smith on 3/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "AALPActivityViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

@interface AALPActivityViewController ()

@end

@implementation AALPActivityViewController
@synthesize timerLabel, workoutTimer, endTime, startTime, started, heartLabel, heartrate, calorieLabel, calories, startButton, minutes, seconds, healthStore, heartRateQuery, lastHeartRateCheck,heartRateTimer,calorieTimer,lastCalorieCheck;

- (void)viewDidLoad {
    [super viewDidLoad];
    started = NO;
    minutes = 0;
    seconds = 0;
    calories = 0;
    heartrate = 0;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startWorkout:(id)sender {
    //1. Check to see if timer is running
    //2. If running, stop timer and reset UI and save data
    //3. If not running, start timer onClick of start.
    //4. Update UI
    //5. Repeat step 4 until user stops timer
    
    if (started) {
        
        
    }
    else {
        [self startTimer];
    }
    
}


- (void)startTimer {
    
    startTime = [NSDate date];
    workoutTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateUI:)
                                         userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:workoutTimer forMode:NSDefaultRunLoopMode];
    started = YES;
    [self startHeartRateCheck];
    
}

- (void)stopTimer {
   // [workoutTimer invalidate];
    
    
}

- (void)updateUI:(NSTimer*) timer {
    
    if (seconds == 59) {
        seconds = 0;
        minutes++;
        
    }
    else {
        seconds++;
        
    }
    
    NSString *secondsString;
    
    if (seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%d", seconds];
        
    }
    else {
        secondsString = [NSString stringWithFormat:@"%d", seconds];
    }
    
    NSString *minutesString;
    
    if (minutes <10) {
        minutesString = [NSString stringWithFormat:@"0%d", minutes];
    }
    else {
        minutesString = [NSString stringWithFormat:@"%d", minutes];
    }
    
    if (minutes == 59 && seconds == 59) {
        [self stopTimer];
        return;
    }
    
    [timerLabel setText:[NSString stringWithFormat:@"%@:%@", minutesString, secondsString]];
    
}


- (void) checkHeartrate:(NSTimer*)timer {
    HKSampleType *heartType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSDate *startDate, *endDate;
    if (self.lastHeartRateCheck == nil) {
        startDate = startTime;
    }
    else {
        startDate = self.lastHeartRateCheck;
    }
    self.lastHeartRateCheck = [NSDate date];
    endDate = [NSDate date];
    NSPredicate *predicateHeartRate = [HKQuery predicateForSamplesWithStartDate: startDate endDate: endDate options:HKQueryOptionNone];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heartType predicate:predicateHeartRate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler: ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(!results) {
            NSLog(@"An error occured getting the users heartrate");
        }
        else {
            if ([results count] == 0){
                NSLog(@"results count is zero!");
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the user interface based on the current user's health information.
                    [self updateHeartrateLabel:[results objectAtIndex:0]];
                });
            }
        }
        
    }];
    [self.healthStore executeQuery:query];
}

- (void) startHeartRateCheck {
    [heartLabel setText:@"---"];
    HKSampleType *heartType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//    heartRateQuery = [[HKObserverQuery alloc] initWithSampleType:heartType predicate:nil updateHandler: ^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
//        if (error) {
//            NSLog(@"Error with updating heart : %@",[error localizedDescription]);
//            abort();
//        }
//        else {
//            [self checkHeartrate];
//            completionHandler();
//        }
//    }];
    //[self.healthStore executeQuery:heartRateQuery];
    heartRateTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(checkHeartrate:)
                                         userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:heartRateTimer forMode:NSDefaultRunLoopMode];
}
-(void)startCaloriesBurnedCheck{
    [calorieLabel setText:@"0"];
    HKSampleType *calorieType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    calorieTimer = [NSTimer timerWithTimeInterval:7.0 target:self selector:@selector(checkCaloriesBurned:)userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:calorieTimer forMode:NSDefaultRunLoopMode];
    
}
-(void)checkCaloriesBurned:(NSTimer*)timer{
        HKSampleType *calorieType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    NSDate *startDate, *endDate;
    if (self.lastCalorieCheck == nil) {
        startDate = startTime;
    }
    else {
        startDate = self.lastHeartRateCheck;
    }
    self.lastHeartRateCheck = [NSDate date];
    endDate = [NSDate date];
    NSPredicate *predicateHeartRate = [HKQuery predicateForSamplesWithStartDate: startDate endDate: endDate options:HKQueryOptionNone];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:calorieType predicate:predicateHeartRate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler: ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if(!results) {
            NSLog(@"An error occured getting the users heartrate");
        }
        else {
            if ([results count] == 0){
                NSLog(@"results count is zero!");
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the user interface based on the current user's health information.
                    [self updateHeartrateLabel:[results objectAtIndex:0]];
                });
            }
        }
        
    }];
    [self.healthStore executeQuery:query];
}
- (void) stopHeartRateCheck {
    
    
    
}

- (void) updateHeartrateLabel: (HKQuantitySample*) sample {
    NSLog(@"sample metadata : %@",[sample metadata]);
    //heartrate = sample.quantity;
    HKQuantity *q = sample.quantity;
    NSLog(@"HKQUANTITY VAR : %@",q);
    double heartRateTest = [q doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
    double heartRateTestSeconds = [q doubleValueForUnit:[HKUnit unitFromString:@"count/s"]];
    NSLog(@"HEART RATE GOTTENT OUT OF HKQUANTITY : %f",heartRateTest);
    NSLog(@"HEART RATE SECONDS %f",heartRateTestSeconds);
    NSInteger heartRate = [NSNumber numberWithDouble:heartRateTest].integerValue;
    [heartLabel setText:[NSString stringWithFormat:@"%ld",(long)heartRate]];
    heartrate = heartRate;
   // [q ]
    
}

- (void) saveWorkoutToHealthKit {
    
    NSString * const HKQuantityTypeIdentifierHeartRate;
    
    // This sample uses hard-coded values and performs all the operations inline
    // for simplicity's sake. A real-world app would calculate these values
    // from sensor data and break the operation up using helper methods.
    
    HKQuantity *energyBurned =
    [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
                     doubleValue:425.0];
    
    HKQuantity *distance =
    [HKQuantity quantityWithUnit:[HKUnit mileUnit]
                     doubleValue:3.2];
    
    // Provide summary information when creating the workout.
//    HKWorkout *run = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning
//                                              startDate:start
//                                                endDate:end
//                                               duration:0
//                                      totalEnergyBurned:energyBurned
//                                          totalDistance:distance
//                                               metadata:nil];
    
    // Save the workout before adding detailed samples.
//    [self.healthStore saveObject:run withCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            // Perform proper error handling here...
//            NSLog(@"*** An error occurred while saving the "
//                  @"workout: %@ ***", error.localizedDescription);
//            
//            abort();
//        }
    
        // Add optional, detailed information for each time interval
//        NSMutableArray *samples = [NSMutableArray array];
//        
//        HKQuantityType *distanceType =
//        [HKObjectType quantityTypeForIdentifier:
//         HKQuantityTypeIdentifierDistanceWalkingRunning];
//        
//        HKQuantity *distancePerInterval =
//        [HKQuantity quantityWithUnit:[HKUnit mileUnit]
//                         doubleValue:3.2];
//        
//        HKQuantitySample *distancePerIntervalSample =
//        [HKQuantitySample quantitySampleWithType:distanceType
//                                        quantity:distancePerInterval
//                                       startDate:intervals[0]
//                                         endDate:intervals[1]];
//        
//        [samples addObject:distancePerIntervalSample];
//        
//        HKQuantityType *energyBurnedType =
//        [HKObjectType quantityTypeForIdentifier:
//         HKQuantityTypeIdentifierActiveEnergyBurned];
//        
//        HKQuantity *energyBurnedPerInterval =
//        [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
//                         doubleValue:15.5];
//        
//        HKQuantitySample *energyBurnedPerIntervalSample =
//        [HKQuantitySample quantitySampleWithType:energyBurnedType
//                                        quantity:energyBurnedPerInterval
//                                       startDate:intervals[0]
//                                         endDate:intervals[1]];
//        
//        [samples addObject:energyBurnedPerIntervalSample];
//        
//        HKQuantityType *heartRateType =
//        [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//        
//        HKQuantity *heartRateForInterval =
//        [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"]
//                         doubleValue:95.0];
//        
//        HKQuantitySample *heartRateForIntervalSample =
//        [HKQuantitySample quantitySampleWithType:heartRateType
//                                        quantity:heartRateForInterval
//                                       startDate:intervals[0]
//                                         endDate:intervals[1]];
//        
//        [samples addObject:heartRateForIntervalSample];
//        
//        // Continue adding additional samples here...
//        
//        // Add all the samples to the workout.
//        [self.healthStore
//         addSamples:samples
//         toWorkout:run
//         completion:^(BOOL success, NSError *error) {
//             if (!success) {
//                 // Perform proper error handling here...
//                 NSLog(@"*** An error occurred while adding a "
//                       @"sample to the workout: %@ ***",
//                       error.localizedDescription);
//                 
//                 abort();
//             }
//         }];
//        
//    }];
    
    
}

- (void) saveWorkout {
    
    
    
}
@end

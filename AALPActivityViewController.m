//
//  AALPActivityViewController.m
//  Fit
//
//  Created by Chelsea Smith on 3/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "AALPActivityViewController.h"
#import "HKHealthStore+AAPLExtensions.h"
#define BUTTON_STARTED_COLOR @"#d95780"
#define BUTTON_STOPPED_COLOR @"#57d9b0"
@interface AALPActivityViewController ()

@end

@implementation AALPActivityViewController
@synthesize timerLabel, workoutTimer, endTime, startTime, started, heartLabel, heartrate, calorieLabel, calories, startButton, minutes, seconds, healthStore, heartRateQuery, lastHeartRateCheck,heartRateTimer,calorieTimer,lastCalorieCheck,activeCalories,basilCalories,basilCalorieTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    started = NO;
    minutes = 0;
    seconds = 0;
    calories = 0;
    heartrate = 0;
    activeCalories = 0;
    basilCalories = 0;
    self.actualCalories = 0;
    self.caloriesBurned = [[NSMutableArray alloc]init];
    [calorieLabel setText:@"---"];
    if (self.heartRates == nil){
        self.heartRates = [[NSMutableArray alloc]init];
    }
    
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
-(UIColor*)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
- (IBAction)startWorkout:(id)sender {
    //1. Check to see if timer is running
    //2. If running, stop timer and reset UI and save data
    //3. If not running, start timer onClick of start.
    //4. Update UI
    //5. Repeat step 4 until user stops timer
    
    if (started) {
        //UIColor *startColor = [UIColor alloc]initWithH
        [startButton setBackgroundColor:[self colorFromHexString:BUTTON_STOPPED_COLOR]];
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
        NSLog(@"STOPPING TIMER");
        [self stopTimer];
    }
    else {
        [startButton setBackgroundColor:[self colorFromHexString:BUTTON_STARTED_COLOR]];
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
        NSLog(@"STARTING TIMER");
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
    //[self startCaloriesBurnedCheck];
    //[self startRestingCaloriesBurnedCheck];
}

- (void)stopTimer {
    [[self timerLabel]setText:@"0:00"];
    endTime = [NSDate date];
    if ([workoutTimer isKindOfClass:[NSTimer class]]){
        NSLog(@"workout timer not nil stopping");
        [workoutTimer invalidate];
        workoutTimer = nil;
    }
//    if([heartRateTimer isKindOfClass:[NSTimer class]]){
//        NSLog(@"heartRateTimer timer not nil stopping");
//        [heartRateTimer invalidate];
//        heartRateTimer = nil;
//    }
//    if([calorieTimer isKindOfClass:[NSTimer class]]){
//        NSLog(@"calorieTimer timer not nil stopping");
//        [calorieTimer invalidate];
//        calorieTimer = nil;
//    }
    [self saveWorkout];
    started = NO;
    // save workout.
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
-(void)startRestingCaloriesBurnedCheck{
    if ([[calorieLabel text]isEqualToString:@"---"]==NO){
        [calorieLabel setText:@"---"];
    }
    basilCalorieTimer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(checkBasilCaloriesBurned:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:basilCalorieTimer forMode:NSDefaultRunLoopMode];
}
-(void)startCaloriesBurnedCheck{
    [calorieLabel setText:@"---"];
    HKSampleType *calorieType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    calorieTimer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(checkCaloriesBurned:)userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:calorieTimer forMode:NSDefaultRunLoopMode];
}
-(void)checkCaloriesBurned:(NSTimer*)timer{
    HKSampleType *calorieType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *calType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    NSDate *startDate, *endDate;
//    if (self.lastCalorieCheck == nil) {
//        startDate = startTime;
//    }
//    else {
//        startDate = self.lastCalorieCheck;
//    }
//    self.lastCalorieCheck = [NSDate date];
//    endDate = [NSDate date];
//    NSPredicate *predicateCalorieQuery = [HKQuery predicateForSamplesWithStartDate: startDate endDate: endDate options:HKQueryOptionNone];
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:calorieType predicate:predicateCalorieQuery limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler: ^(HKSampleQuery *query, NSArray *results, NSError *error) {
//        if(!results) {
//            NSLog(@"An error occured getting the users active calories");
//        }
//        else {
//            if ([results count] == 0){
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSLog(@"GOT SOME ACTIVE CALORIES BACK");
//                    // Update the user interface based on the current user's health information.
//                    HKQuantitySample *sample = [results objectAtIndex:0];
//                    int activeCaloriesBurnedForTime = [[NSNumber numberWithDouble:[[sample quantity]doubleValueForUnit:[HKUnit kilocalorieUnit]]]intValue];
//                    activeCalories+=activeCaloriesBurnedForTime;
//                    calories = activeCalories + basilCalories;
//                    [self updateActiveCaloriesLabel];
//                });
//            }
//        }
//        
//    }];
//    [self.healthStore executeQuery:query];
    [self.healthStore aapl_mostRecentQuantitySampleOfType:calType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (error){
            NSLog(@"aapl_mostRecentQuantitySampleOfType ERROR : %@",[error localizedDescription]);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                activeCalories += [[NSNumber numberWithDouble:[mostRecentQuantity doubleValueForUnit:[HKUnit kilocalorieUnit]]]intValue];
                calories = basilCalories + activeCalories;
                [self updateActiveCaloriesLabel];
            });
        }
    }];
}
-(void)checkBasilCaloriesBurned:(NSTimer*)timer{
    HKSampleType *calorieType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
    HKQuantityType *calType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
//    NSDate *startDate, *endDate;
//    if (self.lastBasilCalorieCheck == nil) {
//        startDate = startTime;
//    }
//    else {
//        startDate = self.lastBasilCalorieCheck;
//    }
//    self.lastBasilCalorieCheck = [NSDate date];
//    endDate = [NSDate date];
//    NSPredicate *predicateCalorieQuery = [HKQuery predicateForSamplesWithStartDate: startDate endDate: endDate options:HKQueryOptionNone];
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:calorieType predicate:predicateCalorieQuery limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler: ^(HKSampleQuery *query, NSArray *results, NSError *error) {
//        if(!results) {
//            NSLog(@"BASIL CALORIES ERROR : %@",[error localizedDescription]);
//        }
//        else {
//            if ([results count] == 0){
//            }else{
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    // Update the user interface based on the current user's health information.
//                    NSLog(@"GOT SOME BASIL CALORIES BACK!!!");
//                    HKQuantitySample *sample = [results objectAtIndex:0];
//                    int basilCaloriesBurnedForTime = [[NSNumber numberWithDouble:[[sample quantity]doubleValueForUnit:[HKUnit kilocalorieUnit]]]intValue];
//                    basilCalories+=basilCaloriesBurnedForTime;
//                    calories = basilCalories + activeCalories;
//                    [self updateActiveCaloriesLabel];
//                });
//            }
//        }
//        
//    }];
//    [self.healthStore executeQuery:query];
    [self.healthStore aapl_mostRecentQuantitySampleOfType:calType predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (error){
            NSLog(@"aapl_mostRecentQuantitySampleOfType ERROR : %@",[error localizedDescription]);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                basilCalories += [[NSNumber numberWithDouble:[mostRecentQuantity doubleValueForUnit:[HKUnit kilocalorieUnit]]]intValue];
                calories = basilCalories + activeCalories;
                [self updateActiveCaloriesLabel];
            });
        }
    }];
}
- (void) stopHeartRateCheck {
    [heartLabel setText:@"---"];
    [heartRateTimer invalidate];
    heartRateTimer = nil;
    NSLog(@"INVALIDATING HEARTRATE TIMER!");
}
-(void)stopCaloriesBurnedTimer{
    [calorieLabel setText:@"0"];
    [calorieTimer invalidate];
    calorieTimer = nil;
    NSLog(@"INVALIDATING CALORIES TIMER");
}
-(void)stopRestingCaloriesBurnedTimer{
    if ([[calorieLabel text]isEqualToString:@"---"]==NO){
        [calorieLabel setText:@"---"];
    }
    [basilCalorieTimer invalidate];
    basilCalorieTimer = nil;
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
    [[self heartRates]addObject:[NSNumber numberWithDouble:heartrate]];
    [self updateCaloriesLabelWithCalculation:heartRate];
   // [q ]
    
}
-(void)updateCaloriesLabelWithCalculation:(NSInteger)heartRate{
    NSInteger age = 28;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"HKAge"]isKindOfClass:[NSNumber class]]){
        age = [[[NSUserDefaults standardUserDefaults]objectForKey:@"HKAge"]integerValue];
    }
    double weight = 150;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"HKWeight"]isKindOfClass:[NSNumber class]]){
        weight = [[[NSUserDefaults standardUserDefaults]objectForKey:@"HKWeight"]doubleValue];
    }
    NSDate *currentTime = [NSDate date];
    NSTimeInterval diff = [currentTime timeIntervalSinceDate:startTime]; // in seconds
    double caloriesBurnedCurrent = ((((double)age * 0.09036) + ((double)heartRate * 0.6309) - 55.0969) * ((double)diff/4.184));
    NSNumber *cl = [NSNumber numberWithDouble:caloriesBurnedCurrent];
    int calIntVal = [cl intValue];
    [[self caloriesBurned]addObject:cl];
    int sum = 0;
    for (int i =0; i < [_caloriesBurned count];i++){
         sum += [[[self caloriesBurned]objectAtIndex:i]intValue];
    }
    sum = (sum/[_caloriesBurned count]/60);
    self.actualCalories +=sum;
    NSString *clString = [NSString stringWithFormat:@"%i",self.actualCalories];
    [[self calorieLabel]setText:clString];
    //Calories Burned = [(Age x 0.2017) — (Weight x 0.09036) + (Heart Rate x 0.6309) — 55.0969] x Time / 4.184.
}
-(void) updateActiveCaloriesLabel{
    [calorieLabel setText:[NSString stringWithFormat:@"%i",calories]];
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
    
    NSString * const HKQuantityTypeIdentifierHeartRate;
    
    // This sample uses hard-coded values and performs all the operations inline
    // for simplicity's sake. A real-world app would calculate these values
    // from sensor data and break the operation up using helper methods.
    NSNumber *num = [NSNumber numberWithInt:self.actualCalories];
    double calorieDouble = [num doubleValue];
    HKQuantity *q = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:calorieDouble];
    NSDictionary *metaData = @{@"Workout-Name" : @"Pulse Workout",@"Workout-Type" : @"General Workout"};
        NSTimeInterval diff = [endTime timeIntervalSinceDate:startTime]; // in seconds
        HKWorkout *run = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning
                                                  startDate:startTime
                                                    endDate:endTime
                                                   duration:diff
                                          totalEnergyBurned:q
                                              totalDistance:0
                                                   metadata:metaData];
    
        [self.healthStore saveObject:run withCompletion:^(BOOL success, NSError *error) {
            NSString *msg;
            if (!success) {
                NSLog(@"ERROR : %@",[error localizedDescription]);
                msg = @"Error Saving workout to Apple Health Kit";
            }else{
                msg = @"Workout Saved to Apple health Kit!";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayWorkOutSavedEvent:msg];
                
            });
        }];
    [self stopHeartRateCheck];
    [self stopCaloriesBurnedTimer];
    [self stopRestingCaloriesBurnedTimer];
    calories = 0;
    basilCalories = 0;
    activeCalories = 0;
    heartrate = 0;
    minutes = 0;
    seconds = 0;
    [calorieLabel setText:@"---"];
    
    _heartRates = [[NSMutableArray alloc]init];
    _caloriesBurned = [[NSMutableArray alloc]init];
    self.actualCalories = 0;
}
-(void)displayWorkOutSavedEvent:(NSString*)message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Workout Ended"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

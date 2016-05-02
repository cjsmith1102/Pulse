//
//  WorkoutDataSource.m
//  Fit
//
//  Created by William Stowers on 5/2/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "WorkoutDataSource.h"
@interface WorkoutDataSource(){
    NSMutableArray<NSMutableArray<HKWorkout*>*>*workouts;
    NSMutableDictionary*dictTitles;
    NSMutableArray<NSString*>*dateStrings;
    BOOL workoutsUpdated;
}
@end
@implementation WorkoutDataSource 
-(instancetype)initWithHealthStore:(HKHealthStore*)store{
    self = [super init];
    if (self){
        self.healthstore = store;
        [self setUpData];
    }
    return self;
}
-(instancetype)initWithHealthStore:(HKHealthStore *)store withDelegate:(id<WorkoutDataSourceDelegate>)delegate{
    self = [super init];
    if (self){
        self.healthstore = store;
        self.delegate = delegate;
        [self setUpData];
    }
    return self;
}
-(void)updateDatesDictionary:(NSArray<HKWorkoutEvent*>*)workoutArray{
    
    [dateStrings removeAllObjects];
    [dictTitles removeAllObjects];
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"MM-dd-yyyy"];
    for (HKWorkout *workout in workoutArray){
        NSDate *dateWorkedOut = [workout startDate];
        NSString *dateString = [fmt stringFromDate:dateWorkedOut];
        if ([dateStrings containsObject:dateString]==NO){
            [dateStrings addObject:dateString];
            [dictTitles setObject:[NSNumber numberWithInt:1] forKey:dateString];
        }else{
            if ([[dictTitles allKeys]containsObject:dateString]){
                int current = [[dictTitles objectForKey:dateString]intValue];
                current++;
                [dictTitles setObject:[NSNumber numberWithInt:current] forKey:dateString];
            
            }else{
                [dictTitles setObject:[NSNumber numberWithInt:1] forKey:dateString];
            }
        }
    }
    [dateStrings sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *dt1 = [fmt dateFromString:obj1];
        NSDate *dt2 = [fmt dateFromString:obj2];
        return [dt2 compare:dt1];
    }];
    for (int i =0; i < [dateStrings count];i++){
        NSMutableArray<HKWorkout*> *curentSection = [[NSMutableArray alloc]init];
        for (HKQuantitySample *sm in workoutArray){
            HKWorkout *wk = (HKWorkout*)sm;
            if ([[dateStrings objectAtIndex:i]isEqualToString:[fmt stringFromDate:[wk startDate]]]){
                [curentSection addObject:wk];
            }
        }
        [workouts addObject:curentSection];
    }
}
- (void)fetchLatestData{
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:[HKWorkoutType workoutType]
                                                                 predicate:[self getWorkoutPredicate]
                                                                     limit:HKObjectQueryNoLimit
                                                           sortDescriptors:@[[self getWorkoutSortDescriptor]]
                                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error)
                                  {
                                      
                                      if(!error && results){
                                          [workouts removeAllObjects];
                                          for(HKQuantitySample *samples in results)
                                          {
                                              // your code here
//                                              HKWorkout *workout = (HKWorkout *)samples;
//                                              if (workout!=nil && [workout isKindOfClass:[HKWorkout class]]){
//                                                  [workouts addObject:workout];
//
//                                                  NSDictionary *storedMetaData = [workout metadata];
//                                              }
//                        
//                                              NSLog(@"%@",workout);
                                          }
                                          [self updateDatesDictionary:results];
                                          [[self delegate]workoutsListNeedRefreshing];
                                      }else{
                                          NSLog(@"Error retrieving workouts %@",error);
                                      }
                                  }];
    [[self healthstore]executeQuery:sampleQuery];
}
-(void)setUpData{
    workouts = [[NSMutableArray alloc]init];
    dictTitles = [[NSMutableDictionary alloc]init];
    dateStrings = [[NSMutableArray alloc]init];
}
-(NSPredicate*)getWorkoutPredicate{
    NSPredicate *predicate = [HKQuery predicateForWorkoutsWithWorkoutActivityType:HKWorkoutActivityTypeRunning];
    return predicate;
}
-(NSSortDescriptor*)getWorkoutSortDescriptor{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:HKSampleSortIdentifierStartDate ascending:false];
    return sortDescriptor;
}
#pragma TABLE VIEW DATA SOURCE
#pragma mark - Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [dateStrings count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = [[dictTitles objectForKey:[dateStrings objectAtIndex:section]]integerValue];
    return rows;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [dateStrings objectAtIndex:section];
}
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index{
    return [dateStrings indexOfObject:title];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workoutCell"];
    HKWorkout *indexPathWorkout = [self getWorkoutAtIndexPath:indexPath];
    UILabel *lblWorkoutName = [cell viewWithTag:10];
    UILabel *lblCallories = [cell viewWithTag:20];
    if (indexPathWorkout!=nil && [indexPathWorkout isKindOfClass:[HKWorkout class]]){
        HKQuantity *calorieQuantity = [indexPathWorkout totalEnergyBurned];
        NSLog(@"TOTAL ENERY BURNED : %f",[calorieQuantity doubleValueForUnit:[HKUnit kilocalorieUnit]]);
        if (calorieQuantity!=nil && [calorieQuantity isKindOfClass:[HKQuantity class]]){
            double calories = [calorieQuantity doubleValueForUnit:[HKUnit calorieUnit]];
            NSInteger calorieInt = [[NSNumber numberWithDouble:calories]integerValue];
            if (calorieInt >=0){
                double kiloCalories = [calorieQuantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
                 int calorieInteger = [[NSNumber numberWithDouble:kiloCalories]intValue];
                
                
                NSString *calorieText = [NSString stringWithFormat:@"%i cal",calorieInteger];
                if ([calorieText isEqualToString:@""]==NO){
                [lblCallories setText:calorieText];
                }else{
                    [lblCallories setText:@"NA"];
                }
            }else{
                [lblCallories setText:@"NA"];
            }
        }else{
            [lblCallories setText:@"NA"];
        }
        NSString *workoutName = @"";
        switch([indexPathWorkout workoutActivityType]){
            case HKWorkoutActivityTypeRunning:
                workoutName = @"Running Workout";
                break;
            case HKWorkoutActivityTypeWalking:
                workoutName = @"Walking Workout";
                break;
            case HKWorkoutActivityTypeHiking:
                workoutName = @"Hiking Workout";
                break;
            case HKWorkoutActivityTypeGolf:
                workoutName = @"Golfing Workout";
                break;
            case HKWorkoutActivityTypePlay:
                workoutName = @"Recreational Activity";
                break;
            case HKWorkoutActivityTypeYoga:
                workoutName = @"Yoga Activity";
                break;
            case HKWorkoutActivityTypeDance:
                workoutName = @"Dance Activity";
                break;
            case HKWorkoutActivityTypeOther:
                workoutName = @"Activity Not Stated";
                break;
            case HKWorkoutActivityTypeRugby:
                workoutName = @"Rugby";
                break;
            case HKWorkoutActivityTypeRowing:
                workoutName = @"Rowing";
                break;
            case HKWorkoutActivityTypeBaseball:
                workoutName = @"Baseball";
                break;
            case HKWorkoutActivityTypeCycling:
                workoutName = @"Cycling Activity";
                break;
            case HKWorkoutActivityTypeSwimming:
                workoutName = @"Swimming Activity";
                break;
            case HKWorkoutActivityTypeSoccer:
                workoutName = @"Soccer";
                break;
            case HKWorkoutActivityTypeSurfingSports:
                workoutName = @"Surfing";
                break;
            case HKWorkoutActivityTypePaddleSports:
                workoutName = @"High Performance Paddling";
                break;
            default:
                workoutName = @"Activity Not Stated";
                break;
        }
        [lblWorkoutName setText:workoutName];
        
    }else{
        [lblCallories setText:@"NA"];
        [lblWorkoutName setText:@"Unknown Workout"];
    }
    return cell;
}
-(HKWorkout*)getWorkoutAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] >=[workouts count]){
        return nil;
    }
    return [[workouts objectAtIndex:[indexPath section]]objectAtIndex:[indexPath row]];
}

@end

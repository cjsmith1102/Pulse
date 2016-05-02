//
//  AALPWorkoutViewController.m
//  Fit
//
//  Created by Chelsea Smith on 4/9/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import "AALPWorkoutViewController.h"
#import "HKHealthStore+AAPLExtensions.h"

@interface AALPWorkoutViewController (){
     UIRefreshControl* refreshControl;
    UIActivityIndicatorView *indicator;
}

@end

@implementation AALPWorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self tableView]setDelegate:self];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    self.workoutSource = [[WorkoutDataSource alloc]initWithHealthStore:self.healthStore withDelegate:self];
    [[self tableView]setDataSource:self.workoutSource];
    [[self workoutSource]fetchLatestData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TABLEVIEW DELEGATE FUNCTIONS
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)refresh:(id)sender{
    [self.refreshControl beginRefreshing];
    [[self workoutSource]fetchLatestData];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 50;
//}
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"Workouts";
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 0;
//}
-(void)workoutsListNeedRefreshing{
    NSLog(@"WORKOUTS NEED REFRESHING!!");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"IN ASYNC BLOCK!");
        if(self.refreshControl.isRefreshing){
            NSLog(@"ENDING REFRESHING");
            [self.refreshControl endRefreshing];
        }
        NSLog(@"RELOADING TABLEVIEWS DATA!!!");
        [self.tableView reloadData];
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

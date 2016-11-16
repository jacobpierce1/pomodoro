//
//  ScheduleController.h
//  The Life of Jacob
//
//  Created by edward on 9/20/16.
//  Copyright © 2016 edward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ScheduleController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

// start time and end time on schedule
extern const NSInteger start_time;
extern const NSInteger end_time;
extern const NSInteger time_step;
extern const int num_steps;

// properties: array storing all columns and an array with the list of times
@property (strong, nonatomic) NSMutableArray *schedule_days_and_times;
@property (strong, nonatomic) NSMutableArray *times;

// columns stored in here
@property (strong, nonatomic) NSMutableArray *saturday_schedule;
@property (strong, nonatomic) NSMutableArray *sunday_schedule;
@property (strong, nonatomic) NSMutableArray *monday_schedule;
@property (strong, nonatomic) NSMutableArray * tuesday_schedule;
@property (strong, nonatomic) NSMutableArray *wednesday_schedule;
@property (strong, nonatomic) NSMutableArray *thursday_schedule;
@property (strong, nonatomic) NSMutableArray *friday_schedule;

// methods
- (void) refresh_arrays;


@end

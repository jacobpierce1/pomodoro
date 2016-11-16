//
//  ScheduleController.m
//  The Life of Jacob
//
//  Created by edward on 9/20/16.
//  Copyright © 2016 edward. All rights reserved.
//

#import "ScheduleController.h"

@implementation ScheduleController

const NSInteger start_time = 7.5;
const NSInteger end_time = 24.0;
const NSInteger time_step = .5;



- (int) num_times {
    return round((end_time - start_time) / .5);
    
}


- (NSMutableArray *) schedule_days_and_times {
    
    // READ DATA FROM FILE
    
    _schedule_days_and_times = [[NSMutableArray alloc] initWithCapacity:7];
    
    for (int i=0; i<7; i++) {
        
        NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:self.num_times];
        for (int j=0; j<self.num_times; j++) {
            [temp addObject:@"dick"];
            // NSLog(@"dick");
        }
        [_schedule_days_and_times addObject: temp];
    }
    
    //[self refresh_arrays];
    
    // put the array pointers for columns in here
    return _schedule_days_and_times;
}


- (NSMutableArray *) times {
    if(!_times) {
        _times = [[NSMutableArray alloc] initWithCapacity:self.num_times];
        
        // fill the times
        for (double i=start_time; i<=end_time; i+=.5) {
            NSNumber *temp = [NSNumber numberWithDouble:i];
            [_times addObject: temp];
        }
        
    }
    return _times;
}








///////////////////////////////////////////////////////

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.num_times;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    if ([tableColumn.identifier isEqualToString:@"times"]) {
        return [self.times objectAtIndex:row];
    
    } else if ([tableColumn.identifier isEqualToString:@"saturday_schedule"]) {
        return [self.schedule_days_and_times[0] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"sunday_schedule"]) {
        return [self.schedule_days_and_times[1] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"monday_schedule"]) {
        return [self.schedule_days_and_times[2] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"tuesday_schedule"]) {
        return [self.schedule_days_and_times[3] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"wednesday_schedule"]) {
        return [self.schedule_days_and_times[4] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"thursday_schedule"]) {
        return [self.schedule_days_and_times[5] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"friday_schedule"]) {
        return [self.schedule_days_and_times[6] objectAtIndex:row];
        
    }
    
    else {
        NSLog(@"schedule column not reached");
        return NULL;
    }
    
}

@end

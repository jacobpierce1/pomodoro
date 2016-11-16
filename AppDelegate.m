//
//  AppDelegate.m
//  The Life of Jacob
//
//  Created by edward on 9/17/16.
//  Copyright © 2016 edward. All rights reserved.
//

#import "AppDelegate.h"

// new window class to allow text fields to be used
@interface NewWindow : NSWindow
- (BOOL) canBecomeKeyWindow;
- (BOOL) canBecomeMainWindow;
@end

@implementation NewWindow
- (BOOL) canBecomeKeyWindow {return YES;}
- (BOOL) canBecomeMainWindow {return YES;}
@end


// here the window property is added
@interface AppDelegate ()
@property (strong) IBOutlet NewWindow *window;
@end




@implementation AppDelegate

// CONSTANTS
const int pomodoro_time = 25*60;





// function to initialize the app
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
//    // check status of the window
//    if([_window isKeyWindow] == TRUE) {
//        NSLog(@"isKeyWindow!");
//    }
//    else {
//        NSLog(@"It's not KeyWindow!");
//    }
//    
    // initialize ivars
    pomodoros_completed_today = 0;
    pomodoro_seconds_left = pomodoro_time;
    updating = false;
    
    // set row selected to -1
    self.table_controller.current_row = -1;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:-1];
    [self.pomodoro_table selectRowIndexes:indexSet byExtendingSelection:NO];
    
    // set the current date for pomodoro deadline
    NSDate *current_date = [NSDate date];
    [self.add_task_deadline setDateValue:current_date];
    
    // get current pomodoros completed today
    [self update_pomodoros_completed_label];
    
    // initialize schedule
    // [self.schedule_controller refresh_arrays];
    // [self.schedule reloadData];
    return;
}



- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



// start the pomodoro timer
- (IBAction)handle_start_pomodoro_button: (id) sender {
    updating = true;
    if (self.table_controller.current_row >= 0) {
        updating_row = self.table_controller.current_row;
        [pomodoro_timer invalidate];
        pomodoro_timer = [NSTimer scheduledTimerWithTimeInterval:1.0   target:self   selector:@selector(update_timer)   userInfo:nil   repeats:YES];
    }
}



// function to update the timer
- (void)update_timer{
    if (updating) {
        
        // increment time remaining and update label
        pomodoro_seconds_left--;
        int num_minutes = pomodoro_seconds_left / 60;
        int num_seconds = pomodoro_seconds_left % 60;
        NSString *label = [NSString stringWithFormat:@"%d:%d", num_minutes, num_seconds];
        self.pomodoro_label.stringValue = label;
        
        // check if the timer is finished
        if (pomodoro_seconds_left == 0) [self handle_timer_finished];
    }
}



// things to do when the timer finishes
- (void) handle_timer_finished {
    // stop and reset
    [self stop_timer];
    self.pomodoro_label.stringValue = @"25:00";   // make this editable
    pomodoro_seconds_left = pomodoro_time;
    
    // increment in the archive and reload the table
    NSString *new_count = [NSString stringWithFormat:@"%d", 1+[self.table_controller.current_pomodoros[updating_row][3] intValue]];
    [self editFile:@"current_pomodoros.txt" withRow:updating_row withCol:2 withMsg: new_count];
    [self.pomodoro_table reloadData];
    
    // increment daily_pomodoros
    NSString *daily_pomodoros = [NSString stringWithContentsOfFile:@"daily_pomodoros.txt" encoding:NSUTF8StringEncoding error:NULL];
    NSArray *daily_pomodoros_arr = [daily_pomodoros componentsSeparatedByString:@"\n"];
    NSString *date_string = [self getFormattedDate];
    NSInteger loc = [daily_pomodoros rangeOfString:date_string].location;
    
    // if found increment
    if (loc != NSNotFound) {
        for (int i=0; i<daily_pomodoros_arr.count; i++) {
            NSArray *current_line_arr = [daily_pomodoros_arr[i] componentsSeparatedByString:@"\t"];
            if ([current_line_arr[0] isEqualToString:date_string]) {
                NSString *new_count_str = [NSString stringWithFormat:@"%d", [current_line_arr[1] intValue]+1];
                [self editFile:@"daily_pomodoros.txt" withRow:i withCol:1 withMsg:new_count_str];
            }
            current_line_arr = nil;
        }
        
        // else add line
    } else {
        NSString *new_line = [NSString stringWithFormat:@"%@\t1", date_string];
        [self addLine:@"daily_pomodoros.txt" withRow:daily_pomodoros_arr.count-1 withLine:new_line];
    }
    
    [self update_pomodoros_completed_label];
    
}


// update the pomodoros completed label by reading number of pomodoros completed today from the text file
- (void) update_pomodoros_completed_label {
    
    // preliminaries
    NSString *daily_pomodoros = [NSString stringWithContentsOfFile:@"daily_pomodoros.txt" encoding:NSUTF8StringEncoding error:NULL];
    NSString *date = [self getFormattedDate];
    NSInteger loc = [daily_pomodoros rangeOfString:date].location;
    int current_count = 0;
    
    // if the date is in there, get the count
    if (loc!=NSNotFound) {
        NSArray *rows = [daily_pomodoros componentsSeparatedByString:@"\n"];
        NSArray *line = [rows[0] componentsSeparatedByString:@"\t"];
        current_count = [line[1] intValue];
    } else current_count = 0;
    
    // change the label
    self.pomodoros_completed_label.stringValue = [NSString stringWithFormat:@"%@%d", @"Count: ", current_count];
}



// pause the timer
- (IBAction) handle_pause_pomodoro_button: (id) sender {
    [self stop_timer];
}



// reset the timer and label
- (IBAction)handle_reset_pomodoro_button:(id)sender {
    [self stop_timer];
    pomodoro_seconds_left = pomodoro_time;
    self.pomodoro_label.stringValue = @"25:00";
}




// add task to the table
- (IBAction)handle_add_task_button:(id)sender {
    
    // read from the text fields
    NSString *task_rank = self.add_task_rank.stringValue;
    NSString *task_name = self.add_task_textfield.stringValue;
    NSDate *date = [self.add_task_deadline dateValue];
    
    // check that rank is valid
    int task_rank_int = [task_rank intValue];
    if (task_rank_int < 1 || task_rank_int > self.table_controller.num_active_rows + 1 || [task_rank length]==0) {
        task_rank_int = self.table_controller.num_active_rows + 1;
    }
    
    // convert nsdate to nsstring
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yy"];
    NSString *task_date = [[NSString alloc] initWithString:[df stringFromDate:date]];
    

    // now construct a new message to send, accounting for the new rank
    NSMutableString *msg = [[NSMutableString alloc] init];
    for (int i=0; i<self.table_controller.num_active_rows + 1; i++) {
        
        // this will store temp message to be added to msg
        NSString *tmp;
        // add \n if not the first line
        if (i!=0) [msg appendString:@"\n"];
        
        // put previous entry into file if not the current rank
        if (i < task_rank_int - 1) {

            tmp = [NSString stringWithFormat:@"%@\t%@\t%@", self.table_controller.current_pomodoros[i][1], self.table_controller.current_pomodoros[i][2], self.table_controller.current_pomodoros[i][3]];

        // otherwise use the new data with new count set to 0
        } else if (i == task_rank_int-1){
            tmp = [NSString stringWithFormat:@"%@\t%@\t%@", task_name, task_date, @"0"];
        
        // increment changes after the new entry
        } else {
            tmp = [NSString stringWithFormat:@"%@\t%@\t%@", self.table_controller.current_pomodoros[i-1][1], self.table_controller.current_pomodoros[i-1][2], self.table_controller.current_pomodoros[i-1][3]];
        }
        
        // append to msg
        NSLog(@"here is tmp: %@", tmp);
        [msg appendString:tmp];
    }
    
    // write to file, then read and reload
    [msg writeToFile:@"current_pomodoros.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.pomodoro_table reloadData];
    
    // reset text fields
    [self.add_task_rank setStringValue:@""];
    [self.add_task_textfield setStringValue:@""];
}




// archive the pomodoro by rewriting the file archived_pomodoros.txt
- (IBAction)handle_archive_pomodoro_button:(id)sender {
    
    // format of file: task \t date_last_completed \t total_pomodoro_count
    
    // get current active task
    NSInteger row = self.table_controller.current_row;
    NSString *current_task = self.table_controller.current_pomodoros[row][1];
    int current_count = [self.table_controller.current_pomodoros[row][3] intValue];
    
    // read old file into string
    NSString *filepath = @"archived_pomodoros.txt";
    NSString *file_contents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:NULL];
    
    // message to be written to the file
    NSMutableString *msg = [[NSMutableString alloc] init];
    
    // construct the date since we will need it in either case
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yy"];
    NSString *date_string = [[NSString alloc] initWithString:[df stringFromDate:date]];
    
    // search string for occurrence of task being removed. if not there, add it
    NSInteger loc = [file_contents rangeOfString:current_task].location;
    if (loc == NSNotFound) {
        [msg appendString:file_contents];
        [msg appendString:[NSString stringWithFormat:@"\n%@\t%@\t%@", self.table_controller.current_pomodoros[row][1], date_string, self.table_controller.current_pomodoros[row][3]]];
        
    // else increment the count already in the file and update the date
    } else {
        
        // break each row into an array to check for current task, then increment
        NSArray *rows = [file_contents componentsSeparatedByString:@"\n"];
        for (int i=0; i<rows.count; i++) {
            if (i!=0) [msg appendString:@"\n"];
            NSMutableArray *tmp = [rows[i] componentsSeparatedByString:@"\t"];
            if (![tmp[0] isEqualToString:current_task]) {
                [msg appendString:rows[i]];
            
            } else {
                tmp[1] = date_string;
                tmp[2] = [NSString stringWithFormat:@"%d", [tmp[2] intValue] + current_count];
                [msg appendString:[NSString stringWithFormat:@"%@\t%@\t%@", tmp[0], tmp[1], tmp[2]]];
            }
        }
    }
    
    // write the message to archive
    [msg writeToFile:@"archived_pomodoros.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];

    // read current tasks
    NSString *filepath2 = @"current_pomodoros.txt";
    NSString *file_contents2 = [NSString stringWithContentsOfFile:filepath2 encoding:NSUTF8StringEncoding error:NULL];
    NSArray *rows2 = [file_contents2 componentsSeparatedByString:@"\n"];
    NSMutableString *msg2 = [[NSMutableString alloc] init];
    
    // construct new string
    for (int i=0; i<rows2.count; i++) {
        NSArray *tmp = [rows2[i] componentsSeparatedByString:@"\t"];
        if (![tmp[0] isEqualToString:current_task]) {
            if (i!=0 && [msg2 length]!=0) [msg2 appendString:@"\n"];
            [msg2 appendString:rows2[i]];
        }
    }
    
    // rewrite current task, then reload
    [msg2 writeToFile:filepath2 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.pomodoro_table reloadData];
    return;
}





// this will stop the timer
- (void) stop_timer {
    if (updating) {
        updating = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [pomodoro_timer invalidate];
        });
    }
}



// change entry at row, col to "msg" in the file: file_name
- (void) editFile:(NSString *)file_name withRow:(int)row withCol:(int)col withMsg:(NSString *)msg {
    
    // read in the current file
    NSString *file_contents = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:NULL];
    NSArray *rows = [file_contents componentsSeparatedByString:@"\n"];
    NSMutableString *tmp = [[NSMutableString alloc] init];
    
    // break each row into an array
    for (int i=0; i<rows.count; i++) {
        if (i!=0) [tmp appendString:@"\n"];
        NSMutableArray *line_array = [rows[i] componentsSeparatedByString:@"\t"];

        // check that row and col are in bounds
        if (col>line_array.count-1 || row>rows.count-1) {
            NSLog(@"Error: cannot edit file, row or col is too large");
            NSLog(@"num cols-1, num rows-1: %d, %d", line_array.count-1, rows.count-1);
            return;
        }
        
        // make the required changed
        if (i==row) line_array[col] = msg;
        
        // add everything to tmp
        for (int j=0; j<line_array.count; j++) {
            [tmp appendString:[NSString stringWithFormat:@"%@", line_array[j]]];
            if (j!=line_array.count-1) [tmp appendString:@"\t"];
        }
        line_array = nil;
    }

    // write the message to file
    [tmp writeToFile:file_name atomically:YES encoding:NSUTF8StringEncoding error:nil];
}



// implement function that removes row and returns the row removed.
- (NSString *) removeLine:(NSString *)file_name withRow:(int)row {
    
    // string to store the removed line
    NSMutableString *line_removed = [[NSMutableString alloc] init];
    
    // read in the current file
    NSString *file_contents = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:NULL];
    NSArray *rows = [file_contents componentsSeparatedByString:@"\n"];
    NSMutableString *tmp = [[NSMutableString alloc] init];
    
    // go through each row and perform check for row to be removed
    for (int i=0; i<rows.count; i++) {
        if ([tmp length]!=0 && i!=row) [tmp appendString:@"\n"];
        if (i==row) line_removed = rows[i];
        else [tmp appendString:rows[i]];
    }
    
    // free memory
    
    // write the message to file and return
    [tmp writeToFile:file_name atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"debug: line removed is %@", line_removed);
    return line_removed;
}



// add a line at (int)row to file_name
- (void) addLine:(NSString *)file_name withRow:(int)row withLine:(NSString *)line {
    
    // read in the current file
    NSString *file_contents = [NSString stringWithContentsOfFile:file_name encoding:NSUTF8StringEncoding error:NULL];
    NSArray *rows = [file_contents componentsSeparatedByString:@"\n"];
    NSMutableString *tmp = [[NSMutableString alloc] init];
    
    // go through each row and perform check for row to be added
    for (int i=0; i<rows.count+1; i++) {
        if (i!=0 && [rows[0] length]!=0) [tmp appendString:@"\n"];
        if (i<row) [tmp appendString:rows[i]];
        else if (i==row) [tmp appendString:line];
        else [tmp appendString:rows[i-1]];
    }
    
    // free memory
    
    // write the message to file and return
    [tmp writeToFile:file_name atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return;
}




// this makes a click to the stepper cause a reordering of ranks in the table.
// note that i am using a hack here by making the min and max values of the stepper
// 1 and 0.
- (IBAction)handle_pomodoro_stepper:(id)sender {
    int stepper_value = [self.pomodoro_stepper integerValue];
    int current_row = self.table_controller.current_row;
    int new_row = 0;
    
    // get the position that the current row will be moved to. it is backwards because the arrows
    //correspond to location in the table.
    if (stepper_value == 1) {
        new_row = current_row - 1;
        updating_row--;
    }
    else {
        new_row = current_row + 1;
        updating_row++;
    }
    
    if (new_row < 0 || new_row > self.table_controller.num_active_rows-1) {
        NSLog(@"invalid new_row");
        return;
    }
    
    // switch lines in file by removing the current line and adding it in the new location
    NSString *line_removed = [self removeLine:@"current_pomodoros.txt" withRow:current_row];
    [self addLine:@"current_pomodoros.txt" withRow:new_row withLine:line_removed];
    
    // switch selected row and reload
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:new_row];
    [self.pomodoro_table selectRowIndexes:indexSet byExtendingSelection:NO];
    [self.pomodoro_table reloadData];
    return;
}


// return a formatted version of the current date
- (NSString *) getFormattedDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yy"];
    NSString *date_string = [[NSString alloc] initWithString:[df stringFromDate:date]];
    return date_string;
}





@end

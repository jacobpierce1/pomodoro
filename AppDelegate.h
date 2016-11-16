//
//  AppDelegate.h
//  The Life of Jacob
//
//  Created by edward on 9/17/16.
//  Copyright © 2016 edward. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TableController.h"
#import "ScheduleController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSTimer *pomodoro_timer;
    bool updating;
    int updating_row;
    NSInteger pomodoro_seconds_left;
    int pomodoros_completed_today;
    NSDate *start_time;
}

// PROPERTIES
// pomodoro information labels
@property (strong) IBOutlet NSTextField *pomodoro_label;
@property (strong) IBOutlet NSTextField *pomodoros_completed_label;

// pomodoro buttons
@property (strong) IBOutlet NSButton *pomodoro_start_button;
@property (strong) IBOutlet NSButton *pomodoro_reset_button;
@property (strong) IBOutlet NSButton *pomodoro_pause_button;
@property (strong) IBOutlet NSButton *pomodoro_archive_button;
@property (strong) IBOutlet NSStepper *pomodoro_stepper;


// add task button/field
@property (strong) IBOutlet NSView *add_task_button;
@property (strong) IBOutlet NSTextField *add_task_textfield;
@property (strong) IBOutlet NSDatePicker *add_task_deadline;
@property (strong) IBOutlet NSTextField *add_task_rank;

// table
@property (strong) IBOutlet NSTableView *pomodoro_table;
@property (strong) IBOutlet TableController *table_controller;

// schedule
@property (strong) IBOutlet ScheduleController *schedule_controller;
@property (strong) IBOutlet NSTableView *schedule;


// METHODS
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
- (void) handle_timer_finished;
- (IBAction)handle_start_pomodoro_button:(id)sender;
- (IBAction)handle_pause_pomodoro_button:(id)sender;
- (IBAction)handle_reset_pomodoro_button:(id)sender;
- (void) update_timer;
- (void) stop_timer;
- (void) update_pomodoros_completed_label;

// file handling
- (void) editFile:(NSString *)file_name withRow:(int)row withCol:(int)col withMsg:(NSString *)msg;
- (NSString *) removeLine:(NSString *)file_name withRow:(int)row;
- (void) addLine:(NSString *)file_name withRow:(int)row withLine:(NSString *)line;
- (NSString *) getFormattedDate;

// constants

@end


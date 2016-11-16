//
//  TableController.h
//  The Life of Jacob
//
//  Created by edward on 9/19/16.
//  Copyright © 2016 edward. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

@interface TableController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSMutableArray *col1;
@property (strong, nonatomic) NSMutableArray *col2;
@property (strong, nonatomic) NSMutableArray *col3;
@property (strong, nonatomic) NSMutableArray *col4;
@property (strong, nonatomic) NSMutableArray *current_pomodoros;
@property (assign, nonatomic) NSInteger num_active_rows;
@property (assign, nonatomic) NSInteger current_row;

// methods
- (void) read_current_pomodoros;
- (NSMutableArray *)transposedArray:(NSMutableArray *)twoDArray;

@end

//
//  TableController.m
//  The Life of Jacob
//
//  Created by edward on 9/19/16.
//  Copyright © 2016 edward. All rights reserved.
//

#import "TableController.h"

@implementation TableController


// read from teh file "current_pomodoros.txt"
- (void) read_current_pomodoros {
    
    // initialize _current_pomodoros
    if (!_current_pomodoros) {
        NSLog(@"DEBUGGITY");
        _current_pomodoros = [[NSMutableArray alloc] initWithCapacity:10];
        for (int i=0; i<10; i++) {
            [_current_pomodoros addObject: [NSArray arrayWithObjects: @"", @"", @"", @"", nil]];
        }
    }
    
    // read from file
    NSString *filepath = @"current_pomodoros.txt";
    NSString *file_contents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:NULL];
    
    // check if file is empty; if so zero out teh array
    if ([file_contents isEqualToString:@""]) {
        NSLog(@"empty file read reached");
        for (int i=0; i<10; i++) {
            _current_pomodoros[i] = [NSArray arrayWithObjects: @"", @"", @"", @"", nil];
        }
        return;
    }
    
    // separate rows into array
    NSArray *rows = [file_contents componentsSeparatedByString: @"\n"];
    _num_active_rows = [rows count];
    
    
    // loop through rows
    for (int i=0; i<[rows count]; i++) {
        NSString *tmp = [NSString stringWithFormat:@"%d\t%@", i+1, rows[i]];
        NSArray *row_contents = [tmp componentsSeparatedByString: @"\t"];
        _current_pomodoros[i] = [NSMutableArray arrayWithArray:row_contents];
    }
    
    // add whitespace to the rest of the array
    for (NSInteger i=[self num_active_rows]; i<10 - [rows count]; i++) {
        _current_pomodoros[i] = [NSMutableArray arrayWithObjects: @"", @"", @"", @"", nil];
        
    }
    return;
}


// call the function to read file and return the array we need
- (NSMutableArray *) current_pomodoros {
    if (!_current_pomodoros) [self read_current_pomodoros];
    return _current_pomodoros;
}





// return transpose of matrix
-(NSMutableArray *)transposedArray:(NSMutableArray *)twoDArray {
    NSUInteger rows = (int) twoDArray.count;
    NSMutableArray *a = twoDArray[0];
    NSUInteger cols = a.count;
    
    NSMutableArray *transposedTwoDArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i<cols; i++)
    {
        NSMutableArray *rowArr = [[NSMutableArray alloc] init];
        for(int j=0; j<rows; j++)
        {
            [rowArr addObject:twoDArray[j][i]];
        }
        [transposedTwoDArray addObject:rowArr];
    }
    
    return transposedTwoDArray;
}



// these functions need to be implemented to generate the table.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.current_pomodoros.count;
}


// populate the table
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    [self read_current_pomodoros];
    
    if ([tableColumn.identifier isEqualToString:@"col1"]) {
        return [[self transposedArray:self.current_pomodoros][0] objectAtIndex:row];
        
    } else if ([tableColumn.identifier isEqualToString:@"col2"]) {
        return [[self transposedArray:self.current_pomodoros][1] objectAtIndex:row];
    
    } else if ([tableColumn.identifier isEqualToString:@"col3"]) {
        return [[self transposedArray:self.current_pomodoros][2] objectAtIndex:row];

    } else if ([tableColumn.identifier isEqualToString:@"col4"]) {
        return [[self transposedArray:self.current_pomodoros][3] objectAtIndex:row];
    }

    else {
        NSLog(@"column not recognized");
        return NULL;
    }
}



// disable selection of some rows
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    if(rowIndex > _num_active_rows - 1) return NO;
    return YES;
}



// get the currently selected row
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSTableView *tableView = notification.object;
    self.current_row = [tableView selectedRow];
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}

@end

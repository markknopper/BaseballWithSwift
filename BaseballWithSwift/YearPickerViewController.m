//
//  YearPickerViewController.m
//
//  Created by Matthew Jones on 4/7/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "YearPickerViewController.h"
#import "BaseballQueryAppDelegate.h"
#import "StatHead.h"

#define DIGIT_SIZE 42.0

@implementation  YearPickerViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	_titleLabel.text = _titleLabelText; // Use label remind user what to enter on this screen.
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {	
	[super viewWillAppear:animated];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    // self.context is PICK000000 for beginning year and PICK000001 for ending year.
    self.pickedValue = [self.context hasSuffix:@"0"] ? [StatHead firstYearInHistory] : @(appDel.latest_year_in_database);
    NSInteger num = [_pickedValue integerValue]; // Default value, eg. 2011.
    _pickedValueLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
    // Make tumblers display default digits.
	for (int i=0; i<4; i++) {
        NSInteger this_digit = num % 10;
        if (i==3) {
            this_digit--; // Thousands has 1 or 2 (no zero).
        }
        [_objectPicker selectRow:this_digit inComponent:(4-1-i) animated:NO];
        num = num / 10;    // toss away lower bits
	}
}

#pragma mark -
#pragma mark UIPickerView Delegate methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSInteger base_row = row;
	if (component==0) { // Can only have 1 or 2 as thousands digit. 
		// thousands column. Start at 1.
		base_row++; 
	}
	return [NSString stringWithFormat:@"%ld", (long)base_row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger num = 0;
        for (int i=0; i<=3; i++) {
            NSInteger digit_read = [pickerView selectedRowInComponent:i];
            if (i==0) digit_read += 1; // thousands have 1 or 2.
            num = num * 10 + digit_read;
        }
    _pickedValueLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
    self.pickedValue = @(num);
}

// DIGIT_SIZE of 42 for height & width makes it nicely smaller than whatever the default is.
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return DIGIT_SIZE;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return DIGIT_SIZE;
}

#pragma mark -
#pragma mark UIPickerView Datasource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
		return 2; // 1 or 2 for thousands digit in year.
	} else {
		return 10;
	}
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender {
    // Do range check 1871-latest.
    NSInteger answer = [_pickedValue integerValue];
    BaseballQueryAppDelegate *appDel = (BaseballQueryAppDelegate *)[[UIApplication sharedApplication] delegate];
    // If out of bounds, save with closed valid value.
    if (answer<1871) self.pickedValue = @1871;
    if (answer>appDel.latest_year_in_database) self.pickedValue = @(appDel.latest_year_in_database);
	[_delegate yearPickerViewController:self didFinishWithSave:YES];
}

- (IBAction)cancel:(id)sender {
	[_delegate yearPickerViewController:self didFinishWithSave:NO];
}

@end

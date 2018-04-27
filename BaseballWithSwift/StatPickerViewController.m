//
//  StatPickerViewController.m
//  BaseballQuery
//
//  Created by Mark Knopper on 3/24/11.
//  Copyright 2011-2015 Bulbous Ventures LLC. All rights reserved.
//

#import "StatPickerViewController.h"
#import <QuartzCore/QuartzCore.h>

/* Generate a picker view inside an action sheet which animates up from the tab bar. */

@implementation StatPickerViewController

-(void)viewWillAppear:(BOOL)animated
// Can't do loadView - makes the window black.
{
    self.titleLabel.text = [NSString stringWithFormat:@"Select a %@ Stat",_titleLabelText];
    self.pickedValueLabel.text = [_statsChoices objectAtIndex:[_actionPickerStoryBoard selectedRowInComponent:0]];
    [super viewWillAppear:animated];
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component>0) return nil;
    return _statsChoices[row];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_statsChoices count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _pickedValueLabel.text = [_statsChoices objectAtIndex:row];
}

#pragma mark -
#pragma mark Save and cancel operations

- (IBAction)save:(id)sender {
    [_delegate pickerDidSelectAStatAtRow:[_actionPickerStoryBoard selectedRowInComponent:0]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end

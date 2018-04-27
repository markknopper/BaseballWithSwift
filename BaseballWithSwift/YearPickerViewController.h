//
//  YearPickerViewController.h
//
//  Created by Matthew Jones on 4/7/10.
//  Copyright 2010-2018 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;

@protocol YearPickerDelegate<NSObject>

-(void)yearPickerViewController:(UIViewController *)viewController didFinishWithSave:(BOOL)save;

@end

@interface YearPickerViewController : UIViewController {
	NSArray *pickerObjects;
}

// context is $PICK000000 for beginning year, or $PICK000001 for ending year.
@property (nonatomic, strong) id context; // opaque data to be used by the delegate
// pickedValue is the year value picked.
@property (nonatomic, strong) NSNumber *pickedValue;
@property (nonatomic, weak) IBOutlet UIPickerView *objectPicker;
@property (nonatomic, unsafe_unretained) id<YearPickerDelegate> delegate;
@property (nonatomic) NSString *titleLabelText; // Caller can set text here, then we display it in viewDidLoad.
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedValueLabel;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

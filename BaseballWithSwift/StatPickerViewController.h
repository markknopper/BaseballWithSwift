//
//  StatPickerViewController.h
//  BaseballQuery
//
//  Created by Mark Knopper on 3/24/11.
//  Copyright 2011-2015 Bulbous Ventures LLC. All rights reserved.
//
@import UIKit;

@class StatPickerViewController;

@protocol StatPickerViewControllerDelegate <NSObject>
-(void)pickerDidSelectAStatAtRow:(NSInteger)selected_picker_row;
@end

@interface StatPickerViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *statsChoices;
@property (assign) CGRect row_rect;
@property (nonatomic, strong) id<StatPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger selected_section;
@property (weak, nonatomic) IBOutlet UIPickerView *actionPickerStoryBoard;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickedValueLabel;
@property (strong, nonatomic) NSString *titleLabelText;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end

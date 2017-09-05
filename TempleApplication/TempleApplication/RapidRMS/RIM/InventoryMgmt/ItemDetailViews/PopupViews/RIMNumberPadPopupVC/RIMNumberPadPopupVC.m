//
//  MMDNumberPickerVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "RIMNumberPadPopupVC.h"
#import "SelectUserOptionVC.h"
#import "RmsDbController.h"

@interface RIMNumberPadPopupVC ()<UIPopoverPresentationControllerDelegate> {
    NSString * strInputValue;
    NSString * strInputUnitTypeValue;
}
@property (nonatomic, weak) IBOutlet UILabel * lblInputNumber;
@property (nonatomic, weak) IBOutlet UIButton * btnUnitType;
@property (nonatomic, weak) IBOutlet UIView * viewUnitSepreter;

@end

@implementation RIMNumberPadPopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    strInputValue = @"";
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (!self.multiplierUnit) {
        self.multiplierUnit = @(1);
    }
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.pickerType == NumberPadPickerTypesQTYFloat) {
        UIButton * btnDot = [self.view viewWithTag:11];
        [btnDot setTitle:@"." forState:UIControlStateNormal];
    }
    if (self.pickerType == NumberPadPickerTypesWeightScale) {
        strInputUnitTypeValue = @"";
        self.btnUnitType.hidden = FALSE;
        self.viewUnitSepreter.hidden = FALSE;
        CGRect frame = self.lblInputNumber.frame;
        frame.size.width = frame.size.width-40;
        self.lblInputNumber.frame = frame;
    }
    [self reSetLableText];
    if (self.view.superview) {
        self.view.superview.layer.cornerRadius = 0;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction -

-(IBAction)btnNumberPadTapped:(UIButton *)sender {
    NSString * tempString = [NSString stringWithFormat:@"%@",strInputValue];
    if (sender.tag == 10) {
        tempString = [tempString stringByAppendingFormat:@"0"];
    }
    else if (sender.tag == 11){
        if (self.pickerType == NumberPadPickerTypesQTYFloat) {
            if (![tempString containsString:@"."]) {
                tempString = [tempString stringByAppendingFormat:@"%@",sender.titleLabel.text];
            }
        }
        else{
            tempString = [tempString stringByAppendingFormat:@"%@",sender.titleLabel.text];
        }
    }
    else {
        tempString = [tempString stringByAppendingFormat:@"%d",(int)sender.tag];
    }
    switch (self.pickerType) {
        case NumberPadPickerTypesQTY:
        case NumberPadPickerTypesQTYFloat:
        case NumberPadPickerTypesWeightScale: {
            break;
        }
        case NumberPadPickerTypesFloat:
        case NumberPadPickerTypesPrice:
        case NumberPadPickerTypesPercentage :{
            tempString = [tempString  stringByReplacingOccurrencesOfString:@"." withString:@""];
            while (tempString.length<3) {
                tempString = [NSString stringWithFormat:@"0%@",tempString];
            }
            NSString * first = [tempString substringToIndex:1];
            if (tempString.length > 3 && [first isEqualToString:@"0"]) {
                tempString = [tempString substringFromIndex:1];
            }
            tempString = [self addDotInString:tempString];
            break;
        }
    }
    if ((!self.maxInput) || (self.maxInput && tempString.floatValue * self.multiplierUnit.floatValue <= self.maxInput.floatValue)) {
        strInputValue = tempString;
    }
    [self reSetLableText];
}
-(NSString *)addDotInString :(NSString *) newString {
    newString = [newString  stringByReplacingOccurrencesOfString:@"." withString:@""];
    while (newString.length<3) {
        newString = [NSString stringWithFormat:@"0%@",newString];
    }
    NSString * first = [newString substringToIndex:1];
    if (newString.length > 3 && [first isEqualToString:@"0"]) {
        newString = [newString substringFromIndex:1];
    }
    newString = [NSString stringWithFormat:@"%@.%@",[newString substringToIndex:newString.length-2],[newString substringFromIndex:newString.length-2]];
    return newString;
}
-(IBAction)btnClearLast:(id)sender {

    if (strInputValue.length > 0) {
        strInputValue = [strInputValue substringToIndex:strInputValue.length-1];
    }
    switch (self.pickerType) {
        case NumberPadPickerTypesQTY:
        case NumberPadPickerTypesQTYFloat:
        case NumberPadPickerTypesWeightScale: {
            break;
        }
        case NumberPadPickerTypesFloat:
        case NumberPadPickerTypesPrice:
        case NumberPadPickerTypesPercentage: {
            strInputValue = [self addDotInString:strInputValue];
            break;
        }
    }
    [self reSetLableText];
}

-(void)reSetLableText {
    switch (self.pickerType) {
        case NumberPadPickerTypesQTY:
        case NumberPadPickerTypesQTYFloat: {
            _lblInputNumber.text = [NSString stringWithFormat:@"%@",strInputValue];
            break;
        }
        case NumberPadPickerTypesFloat: {
            _lblInputNumber.text = [NSString stringWithFormat:@"%@",strInputValue];
            break;
        }
        case NumberPadPickerTypesPrice: {
            _lblInputNumber.text = [NSString stringWithFormat:@"$ %@",strInputValue];
            break;
        }
        case NumberPadPickerTypesPercentage: {
            _lblInputNumber.text = [NSString stringWithFormat:@"%@ %%",strInputValue];
            break;
        }
        case NumberPadPickerTypesWeightScale: {
            if (strInputUnitTypeValue.length > 0) {
                _lblInputNumber.text = [NSString stringWithFormat:@"%@/%@",strInputValue,strInputUnitTypeValue];
            }
            else{
                _lblInputNumber.text = strInputValue;
            }
            break;
        }
    }
}
-(IBAction)btnEnterTapped:(UIButton *)sender {
    if (self.numberPadCompleteInput) {
        NSNumber * inputNumber = @(strInputValue.floatValue);
        if (self.pickerType == NumberPadPickerTypesWeightScale && strInputUnitTypeValue.length == 0) {
            [self btnSelectInputTypeTapped:self.btnUnitType];
        }
        else{
            self.numberPadCompleteInput(inputNumber,strInputUnitTypeValue,self.inputView);
            if (self.isAutoClose) {
                self.numberPadColseInput(self);
            }
        }
    }
}
-(IBAction)btnCloseTapped:(id)sender {
    self.numberPadColseInput(self);
}

-(IBAction)btnClearAllTextTapped:(id)sender {
    strInputUnitTypeValue = @"";
    strInputValue = @"";
    [self reSetLableText];
}

-(IBAction)btnSelectInputTypeTapped:(id)sender {
    SelectUserOptionVC * selectUserOptionVC = [SelectUserOptionVC setSelectionViewitem:@[@"gr",@"kg",@"lb",@"oz"] OptionId:@(0) isMultipleSelectionAllow:false SelectionComplete:^(NSArray *arrSelection) {
        strInputUnitTypeValue = arrSelection[0];
        [self reSetLableText];
    } SelectionColse:^(UIViewController * popUpVC){
        [((SelectUserOptionVC *) popUpVC) popoverPresentationControllerShouldDismissPopover];
    }];
    [selectUserOptionVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionLeft];
}

#pragma mark - UIPopoverPresentationController -

+(instancetype)getInputPopupWith:(NumberPadPickerTypes) pickerType NumberPadCompleteInput:(RIMNumberPadCompleteInput)CompleteInput NumberPadColseInput:(RIMNumberPadColseInput)ColseInput{
    RIMNumberPadPopupVC * instance = [[RIMNumberPadPopupVC alloc]initWithNibName:@"RIMNumberPadPopupVC" bundle:nil];
    instance.numberPadCompleteInput = CompleteInput;
    instance.numberPadColseInput = ColseInput;
    instance.isAutoClose = true;
    instance.pickerType = pickerType;
    return instance;
}

@end

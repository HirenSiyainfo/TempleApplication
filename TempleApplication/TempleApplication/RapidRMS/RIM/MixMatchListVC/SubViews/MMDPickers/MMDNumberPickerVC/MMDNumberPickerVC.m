//
//  MMDNumberPickerVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDNumberPickerVC.h"

@interface MMDNumberPickerVC () {
    NSString * strInputValue;
}

@property (nonatomic, weak) IBOutlet UILabel * lblPickerTitle;
@property (nonatomic, weak) IBOutlet UILabel * lblInputNumber;

@end

@implementation MMDNumberPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    strInputValue = @"";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setStrTitle:(NSString *)strTitle {
    _lblPickerTitle.text = strTitle;
}

#pragma mark - IBAction -

-(IBAction)btnNumberPadTapped:(UIButton *)sender {
//    NSString * strInpitLenght = [strInputValue  stringByReplacingOccurrencesOfString:@"." withString:@""];
//    if (self.maxLength > 0 && (strInpitLenght.length > (self.maxLength - 1))) {
//        return;
//    }
    NSString * tempString = [NSString stringWithFormat:@"%@",strInputValue];
    if (sender.tag == 10) {
        tempString = [tempString stringByAppendingFormat:@"0"];
    }
    else if (sender.tag == 11){
//        if (self.maxLength > 0 && (strInpitLenght.length+1 > (self.maxLength - 1))) {
//            return;
//        }
        tempString = [tempString stringByAppendingFormat:@"00"];
    }
    else {
        tempString = [tempString stringByAppendingFormat:@"%d",(int)sender.tag];
    }
    tempString = [tempString  stringByReplacingOccurrencesOfString:@"." withString:@""];
    switch (self.pickerType) {
        case NumberPickerTypesQTY: {

            break;
        }
        case NumberPickerTypesPrice:
        case NumberPickerTypesPercentage: {
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
    if ((!self.maxInput) || (self.maxInput && tempString.floatValue<=self.maxInput.floatValue)) {
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
        case NumberPickerTypesQTY: {
            break;
        }
        case NumberPickerTypesPrice:
        case NumberPickerTypesPercentage: {
            strInputValue = [self addDotInString:strInputValue];
            break;
        }
    }
    [self reSetLableText];
}
-(void)reSetLableText {
    switch (self.pickerType) {
        case NumberPickerTypesQTY: {
            _lblInputNumber.text = [NSString stringWithFormat:@"%@",strInputValue];
            break;
        }
        case NumberPickerTypesPrice: {
            _lblInputNumber.text = [NSString stringWithFormat:@"$ %@",strInputValue];
            break;
        }
        case NumberPickerTypesPercentage: {
            _lblInputNumber.text = [NSString stringWithFormat:@"%@ %%",strInputValue];
            break;
        }
    }
}
-(IBAction)btnEnterTapped:(id)sender {
    if ([self.Delegate respondsToSelector:@selector(didEnterNumber:inputView:withPickerType:)]) {
        NSNumber * inputNumber = @(strInputValue.floatValue);
        [self.Delegate didEnterNumber:inputNumber inputView:self.inputView withPickerType:self.pickerType];
    }
}
-(IBAction)btnCloseTapped:(id)sender {
    if ([self.Delegate respondsToSelector:@selector(didCancelEditItemPopOver)]) {
        [self.Delegate didCancelEditItemPopOver];
    }
}
@end

//
//  UserInputTextVC.m
//  RapidRMS
//
//  Created by Siya9 on 10/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "UserInputTextVC.h"
#import "RmsDbController.h"
#import "NSString+Methods.h"


@interface UserInputTextVC ()<UIPopoverPresentationControllerDelegate>
@property (nonatomic, weak) IBOutlet UIButton * btnSave;
@property (nonatomic, weak) IBOutlet UIButton * btnCancel;
@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UILabel * lblSubTitle;
@property (nonatomic, weak) IBOutlet UITextView * txtView;
@property (nonatomic, weak) IBOutlet UITextField * txtField;
@end

@implementation UserInputTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.txtView) {
        [self.txtView becomeFirstResponder];
    }
    else if (self.txtField) {
        [self.txtField becomeFirstResponder];
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.strTitle) {
        self.lblTitle.text = self.strTitle.uppercaseString;
    }
    if (self.strSubTitle) {
        self.lblSubTitle.text = self.strSubTitle.uppercaseString;
    }
    if (self.strImputPlaceHolder) {
        self.txtField.placeholder = self.strImputPlaceHolder.uppercaseString;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(instancetype)setInputTextFieldViewitem:(NSString *)InputValue InputTitle:(NSString *)strTitle InputSubTitle:(NSString *)strSubTitle InputSaved:(InputSaved)inputSaved InputClosed:(InputClosed)inputClosed {
    UserInputTextVC * instance = [UserInputTextVC getViewFromStoryBoardSID:@"UserInputTextVCTextField_sid"];
    instance.strInputValue = InputValue;
    instance.strTitle = strTitle;
    instance.strSubTitle = strSubTitle;
    instance.inputSaved = inputSaved;
    instance.inputClosed = inputClosed;
    instance.isBlankInputSaved = TRUE;
    return instance;
}

+(instancetype)setInputTextViewViewitem:(NSString *)InputValue InputTitle:(NSString *)strTitle InputSaved:(InputSaved)inputSaved InputClosed:(InputClosed)inputClosed {
    UserInputTextVC * instance = [UserInputTextVC getViewFromStoryBoardSID:@"UserInputTextVC_sid"];
    instance.strInputValue = InputValue;
    instance.strTitle = strTitle;
    instance.inputSaved = inputSaved;
    instance.inputClosed = inputClosed;
    instance.isBlankInputSaved = TRUE;
    return instance;
}
+(instancetype)getViewFromStoryBoardSID:(NSString *) strSid{
    return (UserInputTextVC *)[[UIStoryboard storyboardWithName:RIMStoryBoard() bundle:NULL] instantiateViewControllerWithIdentifier:strSid];
}

#pragma mark - IBAction -
-(IBAction)btnsaveclick:(UIButton *)sender {
    
    NSString * strInput = @"";
    if (self.txtView && self.txtView.text.length > 0) {
        strInput = self.txtView.text;
    }
    else if (self.txtField && self.txtField.text.length > 0) {
        strInput = self.txtField.text;
    }
    if ((self.isBlankInputSaved || strInput.length > 0 ) && ([strInput isBlank] == NO)) {
        self.inputSaved(strInput);
        self.inputClosed(self);
    }
    else {
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        if (!self.strImputErrorMessage || self.strImputErrorMessage.length == 0) {
            self.strImputErrorMessage = @"Please Input Value";
        }
        [[RmsDbController sharedRmsDbController] popupAlertFromVC:self title:@"" message:self.strImputErrorMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
-(IBAction)btnCancleclick:(UIButton *)sender {
    [self popoverPresentationControllerShouldDismissPopover];
}
//-(void)presentViewControllerForViewController:(UIViewController *)viewController{
//    
//    self.modalPresentationStyle = UIModalPresentationPopover;
//    
//    CGRect frame = self.view.frame;
//    
//    self.preferredContentSize = frame.size;
//    [viewController presentViewController:self animated:YES completion:nil];
//    
//    UIPopoverPresentationController * popup =self.popoverPresentationController;
//    
//    popup.permittedArrowDirections = (UIPopoverArrowDirection)NULL;
//    popup.sourceView = self.view;
//    popup.delegate = self;
//    
//    popup.sourceRect = [self getCenterFrameView:viewController.view];
//    
//}
//-(CGRect)getCenterFrameView:(UIView *)bgView{
//    
//    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    frame.origin.x = (bgView.bounds.size.width - frame.size.width)/2;
//    frame.origin.y = (bgView.bounds.size.height - frame.size.height)/2;
//    
//    //    frame.origin.y = frame.origin.y - 50;
//    return frame;
//}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if (IsPhone()) {
        [self popoverPresentationControllerShouldDismissPopover];
        return false;
    }
    else{
        return TRUE;
    }
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    self.inputClosed(self);
}

@end

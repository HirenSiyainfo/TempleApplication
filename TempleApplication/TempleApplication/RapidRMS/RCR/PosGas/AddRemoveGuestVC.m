//
//  AddRemoveGuestVC.m
//  RapidRMS
//
//  Created by Siya on 07/05/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "AddRemoveGuestVC.h"
#import "RmsDbController.h"

@interface AddRemoveGuestVC ()

@property (nonatomic, weak) IBOutlet UITextField *txtGuest;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation AddRemoveGuestVC
@synthesize addRemoveGuestDelegate,guestCount,isdescressGuest,txtTableName,tableName;

- (void)viewDidLoad {
    [super viewDidLoad];
   /// NSDateComponents *a =
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    _txtGuest.text = [NSString stringWithFormat:@"%@",guestCount];
    self.txtTableName.text = [NSString stringWithFormat:@"%@",tableName];
    // Do any additional setup after loading the view.
}

-(IBAction)increaseGuest:(id)sender{
    int guest = _txtGuest.text.intValue+1;
    _txtGuest.text = [NSString stringWithFormat:@"%d",guest];
}

-(IBAction)decreaseGuest:(id)sender{
    
    if(isdescressGuest && _txtGuest.text.intValue>1){
        int guest = _txtGuest.text.intValue-1;
        _txtGuest.text = [NSString stringWithFormat:@"%d",guest];
    }
}
-(IBAction)doneClick:(id)sender{
    NSInteger numguest = _txtGuest.text.intValue;
    [addRemoveGuestDelegate updateGuestCount:numguest withtableName:self.txtTableName.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)cancelClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

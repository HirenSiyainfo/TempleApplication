//
//  ModuleActiveUserInfoVC.m
//  RapidRMS
//
//  Created by Siya-mac5 on 05/08/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "ModuleActiveDeactiveSideInfoVC.h"
#import "RmsDbController.h"
#import "ActiveUserListCell.h"
#import "RmsActivityIndicator.h"


@interface ModuleActiveDeactiveSideInfoVC ()
{
    NSIndexPath * deleteOrderIndPath;
}

@property (nonatomic, weak) IBOutlet UILabel *lblActiveApp;
@property (nonatomic, weak) IBOutlet UILabel *lblReleaseApp;
@property (nonatomic, weak) IBOutlet UILabel *lblStoreName;
@property (nonatomic, weak) IBOutlet UILabel *lblStoreAddress;

@property (nonatomic, weak) IBOutlet UIButton *btnAvailableApp;
@property (nonatomic, weak) IBOutlet UIButton *btnActiveApp;
@property (nonatomic, weak) IBOutlet UIButton *btnRelease;

@property (nonatomic, weak) IBOutlet UIView *viewActiveRegInfo;
@property (nonatomic, weak) IBOutlet UIView *viewReleaseRegInfo;
@property (nonatomic, weak) IBOutlet UIView *buttonContainer;

@property (nonatomic, weak) IBOutlet UITableView *tblActiveRegisterInfo;
@property (nonatomic, weak) IBOutlet UITableView *tblReleaseRegisterInfo;

@property (nonatomic, weak) IBOutlet UIImageView *largeProfilePic;

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, strong) RapidWebServiceConnection *moduleActiveDeactiveWC;

@property (nonatomic, strong) NSMutableArray *activeUserList;



@end

@implementation ModuleActiveDeactiveSideInfoVC
@synthesize isfromDashBoard , arrDeviceAuthentication;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewActiveRegInfo.hidden = YES;
    self.viewReleaseRegInfo.hidden = YES;
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    [self setStoreNameAndStoreAddress];
    [self createActiveUserArray];
    NSString *imageName = @"";
    if (IsPad()) {
        imageName = @"activeUserIcon.png";
    }
    else {
        imageName = @"placeholdericon_iphone.png";
    }
    UIImage *profilePic = [UIImage imageNamed:imageName];
    self.largeProfilePic.layer.cornerRadius = self.largeProfilePic.frame.size.width/2;
    self.largeProfilePic.image = profilePic;
    self.moduleActiveDeactiveWC  = [[RapidWebServiceConnection alloc] init];
    if(self.isfromDashBoard) {
        [self loadAvailableApps:self.btnAvailableApp];
    }
    else {
        if (self.releaseDevices != nil && self.releaseDevices.count > 0) {
            [self loadReleaseApp:self.btnRelease];
        }
        else
        {
            [self loadAvailableApps:self.btnAvailableApp];
        }
    }
    self.lblReleaseApp.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.releaseDevices.count];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setButtonTitle:@"Available\nModules" toButton:self.btnAvailableApp];
    [self setButtonTitle:@"Active\nRegisters" toButton:self.btnActiveApp];
    [self setButtonTitle:@"Released\nRegisters" toButton:self.btnRelease];
    
    [self makeCircleForCountLabel:self.lblAvailableApp withColor:[UIColor colorWithRed:208.0/255.0 green:186.0/255.0 blue:64.0/255.0 alpha:1.0]];
    [self makeCircleForCountLabel:self.lblActiveApp withColor:[UIColor colorWithRed:230.0/255.0 green:161.0/255.0 blue:48.0/255.0 alpha:1.0]];
    [self makeCircleForCountLabel:self.lblReleaseApp withColor:[UIColor colorWithRed:244.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0]];
}

- (void)setButtonTitle:(NSString *)title toButton:(UIButton *)button
{
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    if (IsPad()) {
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    else {
        title = [title uppercaseString];
    }
    button.titleLabel.numberOfLines = 0;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
}

-(void)makeCircleForCountLabel:(UILabel *)label withColor:(UIColor *)color
{
    label.layer.cornerRadius = label.frame.size.width/2;
    label.layer.borderWidth = 3.0;
    label.layer.borderColor = color.CGColor;
}

-(void)setStoreNameAndStoreAddress
{
    [self setValueToLabel:self.lblStoreName fromString:self.storeName];
    [self setValueToLabel:self.lblStoreAddress fromString:self.storeAddress];
}

- (void)setValueToLabel:(UILabel *)label fromString:(NSString *)string
{
    if (string != nil && string.length > 0) {
        label.text = string;
    }
}

-(void)createActiveUserArray {
    self.activeUserList = [[self.activeDevices valueForKeyPath:@"@distinctUnionOfObjects.RegisterNo"] mutableCopy];
    for(int i = 0; i < self.activeUserList.count; i++){
        if([(self.activeUserList)[i] length] == 0){
            [self.activeUserList removeObjectAtIndex:i];
            continue;
        }
        NSMutableDictionary *dictModule = [[NSMutableDictionary alloc]init];
        
        NSPredicate *registerNumberPredicate = [NSPredicate predicateWithFormat:@"RegisterNo == %@", (self.activeUserList)[i]];
        NSMutableArray *arrayRegisterNumber = [[self.activeDevices filteredArrayUsingPredicate:registerNumberPredicate] mutableCopy];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"MacAdd =%@",[self.rmsDbController.globalDict valueForKey:@"DeviceId"]];
        
        NSArray *arrayReg = [arrayRegisterNumber filteredArrayUsingPredicate:predicate];
        
        dictModule[@"RegisterName"] = arrayRegisterNumber[0][@"RegisterName"];
        dictModule[@"RegisterNo"] = (self.activeUserList)[i];

        if(arrayReg.count>0){
            [self.activeUserList insertObject:dictModule atIndex:0];
            [self.activeUserList removeObjectAtIndex:i+1];
        }
        else{
            [self.activeUserList removeObjectAtIndex:i];
            [self.activeUserList insertObject:dictModule atIndex:i];
        }
    }
    self.lblActiveApp.text = [NSString stringWithFormat:@"%lu",(unsigned long) self.activeUserList.count];
}


-(void)configureButtonSelection:(UIButton *)button {
    self.btnActiveApp.selected = false;
    self.btnAvailableApp.selected = false;
    self.btnRelease.selected =false;
    self.viewActiveRegInfo.hidden = YES;
    self.viewReleaseRegInfo.hidden = YES;
    button.selected = true;
}

-(IBAction)loadAvailableApps:(UIButton *)sender {
    [self configureButtonSelection:self.btnAvailableApp];
    self.buttonContainer.backgroundColor = self.viewActiveRegInfo.backgroundColor;
    [self.moduleSelectionChangeDelegate loadAvailableApp];
}

-(IBAction)loadActiveApps:(UIButton *)sender {
    [self configureButtonSelection:self.btnActiveApp];
    [self setColorToButtonContainerUsingCount:self.lblActiveApp.text];
    self.viewActiveRegInfo.hidden = NO;
    [self.moduleSelectionChangeDelegate loadActiveApp];
    [self.tblActiveRegisterInfo
         selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
         animated:TRUE
         scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tblActiveRegisterInfo didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

-(IBAction)loadReleaseApp:(UIButton *)sender {
    [self configureButtonSelection:self.btnRelease];
    [self setColorToButtonContainerUsingCount:self.lblReleaseApp.text];
    self.viewReleaseRegInfo.hidden = NO;
    [self.moduleSelectionChangeDelegate loadReleaseModules];
    [self.tblReleaseRegisterInfo
     selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
     animated:TRUE
     scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tblReleaseRegisterInfo didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)setColorToButtonContainerUsingCount:(NSString *)strCount
{
    if ([strCount isEqualToString:@"0"]) {
        self.buttonContainer.backgroundColor = self.viewActiveRegInfo.backgroundColor;
    }
    else
    {
        self.buttonContainer.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(tableView == self.tblActiveRegisterInfo){
         return self.activeUserList.count;
    }
    else if(tableView == self.tblReleaseRegisterInfo){
        return self.releaseDevices.count;
    }
    else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tblReleaseRegisterInfo && self.btnRelease.selected)
    {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        deleteOrderIndPath = [indexPath copy];
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
            [self.tblReleaseRegisterInfo setEditing:NO];
        };
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {
            _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
            NSString *strBranchID = [self.rmsDbController.globalDict valueForKey:@"BranchID"];
            
            NSMutableDictionary * dictDeviceActivation = [[NSMutableDictionary alloc] init];
            dictDeviceActivation[@"BranchId"] = strBranchID;
            dictDeviceActivation[@"RegisterNo"] = [(self.releaseDevices)[deleteOrderIndPath.row] valueForKey:@"RegisterNo"];
            dictDeviceActivation[@"MacAddress"] = [(self.releaseDevices)[deleteOrderIndPath.row] valueForKey:@"MacAddress"];
            
            CompletionHandler completionHandler = ^(id response, NSError *error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self deleteModuleResponse:response error:error];
                });
            };
            
            self.moduleActiveDeactiveWC = [self.moduleActiveDeactiveWC initWithRequest:KURL actionName:WSM_PERMENANT_RELEASE_REGISTER params:dictDeviceActivation completionHandler:completionHandler];
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Release module" message:@"Are you sure you want to delete this record?" buttonTitles:@[@"No",@"Yes"] buttonHandlers:@[leftHandler,rightHandler]];
    }
    }
}

- (void)deleteModuleResponse:(id)response error:(NSError *)error
{
    [_activityIndicator hideActivityIndicator];
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if([[response valueForKey:@"IsError"] intValue] == 0)
            {
                [self removeReleseRegisterFromDeviceArray];
                [self.releaseDevices removeObjectAtIndex:deleteOrderIndPath.row];
                [self.tblReleaseRegisterInfo reloadData];
                
                self.lblReleaseApp.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.releaseDevices.count];
                
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
            else
            {
                [self.tblReleaseRegisterInfo reloadData];
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Info" message:[response valueForKey:@"Data"] buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
            }
        }
    }
}

-(void)removeReleseRegisterFromDeviceArray
{
    NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"RegisterNo = %@",[(self.releaseDevices)[deleteOrderIndPath.row] valueForKey:@"RegisterNo"]];
    
    NSArray *arrReleseObject = [[self.arrDeviceAuthentication.firstObject valueForKey:@"objReleasedRegisterObject"] filteredArrayUsingPredicate:prdicate];
    if (arrReleseObject != nil && arrReleseObject.count>0)
    {
        NSInteger index = [arrReleseObject indexOfObject:arrReleseObject.firstObject];
        [[self.arrDeviceAuthentication.firstObject valueForKey:@"objReleasedRegisterObject"] removeObjectAtIndex:index];
    }
    
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IsPhone()) {
        return 55.0;
    }
    return 58.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ActiveUserListCell";
    if (IsPad()) {
        cellIdentifier = @"ActiveUserListCell";
    }
    else {
        cellIdentifier = @"ActiveUserListCell_iPhone";
    }

    ActiveUserListCell *activeuserCell = (ActiveUserListCell *)[self.tblActiveRegisterInfo dequeueReusableCellWithIdentifier:cellIdentifier];
    activeuserCell.backgroundColor=[UIColor whiteColor];

    UIView *viewBG = [[UIView alloc] initWithFrame:activeuserCell.bounds];
    if (IsPad()) {
        viewBG.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:212.0/255.0 blue:230.0/255.0 alpha:1.0];
    }
    else {
        viewBG.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    }
    
    activeuserCell.selectedBackgroundView = viewBG;
    if(tableView == self.tblActiveRegisterInfo){
        activeuserCell.lblUserName.text = (self.activeUserList)[indexPath.row][@"RegisterName"];
    }
    else if(tableView == self.tblReleaseRegisterInfo){
        NSMutableDictionary *dictReleaseUser = (self.releaseDevices)[indexPath.row];
        activeuserCell.lblUserName.text = [dictReleaseUser valueForKey:@"RegisterName"];
    }
    return activeuserCell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self setSelectionBackgroundColorToButtonContainerUsingIndexPath:indexPath];
    if(tableView == self.tblActiveRegisterInfo)
    {
        if (self.activeUserList.count > 0) {
            [self.moduleSelectionChangeDelegate loadActiveRegisterModule:(self.activeUserList)[indexPath.row][@"RegisterNo"]];
        }
        else
        {
            self.buttonContainer.backgroundColor = self.viewActiveRegInfo.backgroundColor;
        }
    }
    else if(tableView == self.tblReleaseRegisterInfo)
    {
        if (self.releaseDevices != nil && self.releaseDevices.count > 0) {
            NSString *strUser = [(self.releaseDevices)[indexPath.row] valueForKey:@"RegisterName"];
            [self.moduleSelectionChangeDelegate loadReleaseUserModule:strUser];
        }
        else
        {
            self.buttonContainer.backgroundColor = self.viewActiveRegInfo.backgroundColor;
        }
    }
    else{
        [self.moduleSelectionChangeDelegate loadAvailableApp];
    }
}

- (void)setSelectionBackgroundColorToButtonContainerUsingIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (IsPad()) {
            self.buttonContainer.backgroundColor = [UIColor colorWithRed:205.0/255.0 green:212.0/255.0 blue:230.0/255.0 alpha:1.0];
        }
        else {
            self.buttonContainer.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        }
    }
    else
    {
        self.buttonContainer.backgroundColor = [UIColor whiteColor];
    }
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

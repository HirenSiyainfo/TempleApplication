//
//  MultipleBarcodePopUpVCViewController.m
//  RapidRMS
//
//  Created by Siya Infotech on 21/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "MultipleBarcodePopUpVC.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "MultipleBarcodeCustomCell.h"
#import "ItemBarCode_Md+Dictionary.h"
#import "NSString+Validation.h"


@interface MultipleBarcodePopUpVC () <
#ifdef LINEAPRO_SUPPORTED
DTDeviceDelegate
#endif
>
{
#ifdef LINEAPRO_SUPPORTED
    DTDevices *dtdev;
#endif
    BOOL isScannerUsed;
    NSMutableString *status;
    NSArray * arrFilterList;
    NSString *lastAutoGeneratedUPC;
    NSString *allowToItems;
}
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (nonatomic, strong) RimsController *rimsController;

@property (nonatomic, weak) IBOutlet UITableView * tblbarcodeList;
@property (nonatomic, weak) IBOutlet UITextField * txtbarcodeText;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segItemBarcodeType;


@end

@implementation MultipleBarcodePopUpVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    
    switch (self.editingPackageType) {
        case ItemBarcodeTypeAll:
            self.segItemBarcodeType.selectedSegmentIndex = 0;
            break;
            
        case ItemBarcodeTypeSingleItem:
            self.segItemBarcodeType.selectedSegmentIndex = 0;
            break;
            
        case ItemBarcodeTypeCase:
            self.segItemBarcodeType.selectedSegmentIndex = 1;
            break;
            
        case ItemBarcodeTypePack:
            self.segItemBarcodeType.selectedSegmentIndex = 2;
            break;
            
        default:
            break;
    }
    if(self.editingPackageType != ItemBarcodeTypeAll)
    {
        self.segItemBarcodeType.enabled = NO;
    }
    else
    {
        self.segItemBarcodeType.enabled = YES;
    }
    if (!self.arrItemBarcodeList) {
        self.arrItemBarcodeList = [NSMutableArray array];
    }
#ifdef LINEAPRO_SUPPORTED
    dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [dtdev connect];
#endif
    
    status=[[NSMutableString alloc] init];
    lastAutoGeneratedUPC = @"";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resettableFilterArray];
    [self.tblbarcodeList reloadData];
    if (self.view.superview) {
        self.view.superview.layer.cornerRadius = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.rimsController.scannerButtonCalled=@"MultipleBarcode";
    [self checkConnectedScannerType];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.rimsController.scannerButtonCalled=@"";
}

#pragma mark - IBAction -

- (IBAction)addBarcodeClicked:(UIButton *)sender {
    [self textFieldShouldReturn:self.txtbarcodeText];
}
- (IBAction)deleteBarcodeClicked:(UIButton *)sender {
    NSMutableDictionary * removeObject = [arrFilterList objectAtIndex:sender.tag];
    [self.arrItemBarcodeList removeObject:removeObject];
    
    [self resettableFilterArray];
    [self.tblbarcodeList reloadData];
}
- (IBAction)segmentItemBarcodeTypeChange:(UISegmentedControl *)sender {
    [self resettableFilterArray];
    [self.tblbarcodeList reloadData];
}
- (IBAction)generateUPC:(id)sender
{
    lastAutoGeneratedUPC = [self generateRendomUPCUsingUUID];
    self.txtbarcodeText.text = lastAutoGeneratedUPC;
}

- (IBAction)doneBarcodeInputClicked:(UIButton *)sender {
    BOOL isBarcodeExist = FALSE;
    allowToItems = @"";
    if(self.arrItemBarcodeList.count > 0)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemBarCode_Md" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSArray *barcodeList = [self.arrItemBarcodeList valueForKey:@"Barcode"];
        
//        NSPredicate *barcodePredicate = [NSPredicate predicateWithFormat:@"barCode IN %@ AND itemCode != %@", barcodeList,self.itemCode];
        NSPredicate * itemBarcodePredicate = [NSPredicate predicateWithFormat:@"itemCode != %@",self.itemCode];
        
        NSMutableArray * arrBarcodePredicate = [NSMutableArray array];
        for (NSString * strBarcode in barcodeList) {
            [arrBarcodePredicate addObject:[NSPredicate predicateWithFormat:@"barCode == [cd]%@ ", strBarcode]];
        }
        NSCompoundPredicate * barcodePrecicates = [NSCompoundPredicate orPredicateWithSubpredicates:arrBarcodePredicate];
        
        
        fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[itemBarcodePredicate,barcodePrecicates]];
        
        NSArray *resultSet = [UpdateManager executeForContext:self.managedObjectContext FetchRequest:fetchRequest];
        if(resultSet.count > 0) {
            isBarcodeExist = TRUE;
            for (ItemBarCode_Md *anBarcode in resultSet) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Barcode == [cd]%@", anBarcode.barCode];
                NSArray *isBarcodeResult = [self.arrItemBarcodeList filteredArrayUsingPredicate:predicate];
                isBarcodeResult.firstObject [@"isExist"] = @"YES";
                if(self.isDuplicateBarcodeAllowed)
                {
                    isBarcodeResult.firstObject [@"notAllowItemCode"] = anBarcode.itemCode;
                }
            }
        }
        if(isBarcodeExist)
        {
            if(self.isDuplicateBarcodeAllowed)
            {
                UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isExist == %@", @"YES"];
                    NSArray *isBarcodeResult = [self.arrItemBarcodeList filteredArrayUsingPredicate:predicate];
                    [self.arrItemBarcodeList removeObjectsInArray:isBarcodeResult];
                    [self.tblbarcodeList reloadData];
                };
                UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
                {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isExist == %@", @"YES"];
                    NSArray *isBarcodeResult = [self.arrItemBarcodeList filteredArrayUsingPredicate:predicate];
                    allowToItems = [NSString stringWithFormat:@"%@",[[isBarcodeResult valueForKey:@"notAllowItemCode"] componentsJoinedByString:@","]];
                    [self updateBarcodeInItemDataobject];
                };
                [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"UPC is already exists in other Item which doesn't allow barcode duplication, are you sure you want to allow duplication barcode for current item ?" buttonTitles:@[@"Don't Allow",@"Allow"] buttonHandlers:@[leftHandler,rightHandler]];
            }
            [self.tblbarcodeList reloadData];
        }
        else
        {
            if(self.isDuplicateBarcodeAllowed) {
                [self updateBarcodeInItemDataobject];
            }
            else{
                BOOL isSave = TRUE;
                for (NSMutableDictionary * dictBarcode in self.arrItemBarcodeList) {
                     NSMutableArray * arrBarCodeTypes = [@[@"Single Item",@"Case",@"Pack"] mutableCopy];
                    [arrBarCodeTypes removeObject:dictBarcode[@"PackageType"]];
                    if ([self isBarcode:dictBarcode[@"Barcode"] Duplicatein:arrBarCodeTypes]) {
                        isSave = FALSE;
                        dictBarcode[@"isExist"] = @"YES";
                    }
                }
                if (isSave){
                    [self updateBarcodeInItemDataobject];
                }
                else {
                    [self showMessage:@"Barcode already exist in list"];
                    [self.tblbarcodeList reloadData];
                }
            }
        }
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Add at least one barcode" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        [self checkConnectedScannerType];
    }
}
-(void)updateBarcodeInItemDataobject{
    [self CloseiPhoneBarcodePopup:nil];
//    if(IsPad()){
//        [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
//    }
//    else{
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"IsDefault == %@",@"1"];
    NSArray * arrDefauptBarcode = [self.arrItemBarcodeList filteredArrayUsingPredicate:predicate];
    if (arrDefauptBarcode.count == 0) {
        [self setDefailtBarcode];
    }
    [self.multipleBarcodePopUpVCDelegate didUpdateMultipleBarcode:self.arrItemBarcodeList allowToItems:allowToItems];
}

-(IBAction)CloseiPhoneBarcodePopup:(UIButton *)sender {
    [self popoverPresentationControllerShouldDismissPopover];
}
-(void)setDefailtBarcode{
    NSArray * arrDefauptBarcode = [self getItemBarcodeFromBarcodetype:@"Single Item"];
    if (arrDefauptBarcode.count > 0) {
        arrDefauptBarcode[0][@"IsDefault"] = @"1";
    }
    else{
        NSArray * arrDefauptBarcode = [self getItemBarcodeFromBarcodetype:@"Case"];
        if (arrDefauptBarcode.count > 0) {
            arrDefauptBarcode[0][@"IsDefault"] = @"1";
        }
        else{
            NSArray * arrDefauptBarcode = [self getItemBarcodeFromBarcodetype:@"Pack"];
            if (arrDefauptBarcode.count > 0) {
                arrDefauptBarcode[0][@"IsDefault"] = @"1";
            }
        }
    }
}
#pragma mark - UITextFieldDelegate -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self checkConnectedScannerType];
    if (textField.text.length > 0) {
        [self addNewBarcode:[NSString trimSpacesFromStartAndEnd:textField.text]];
    }
    if (IsPhone()) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(IsPhone()) {
        
        if( textField == _txtbarcodeText) {
            
            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.barStyle = UIBarStyleBlackTranslucent;
            numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(addBarcodeClicked:)]];
            textField.inputAccessoryView = numberToolbar;
        }
    }
    return YES;
}

#pragma mark - Table view data source -

-(void)resettableFilterArray {
    NSString * strBarCodeType = [self getBarcodeTypeString];
    arrFilterList = [self getItemBarcodeFromBarcodetype:strBarCodeType];
    [self.tblbarcodeList reloadData];
}
-(NSString *)getBarcodeTypeString {
    NSString * strBarCodeType = @"";
    switch (self.segItemBarcodeType.selectedSegmentIndex) {
        case 0: {
            strBarCodeType = @"Single Item";
            break;
        }
        case 1: {
            strBarCodeType = @"Case";
            break;
        }
        case 2: {
            strBarCodeType = @"Pack";
            break;
        }
    }
    return strBarCodeType;
}
-(NSArray *)getItemBarcodeFromBarcodetype:(NSString *)strBarcodetype{
    NSPredicate *isBarcodePred = [NSPredicate predicateWithFormat:@"PackageType == %@",strBarcodetype];
    return [self.arrItemBarcodeList filteredArrayUsingPredicate:isBarcodePred];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrFilterList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MultipleBarcodeCell";
    MultipleBarcodeCustomCell *barcodeCell = (MultipleBarcodeCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *barcodeDict = arrFilterList[indexPath.row];
    // Display barcode
    barcodeCell.barcode.text = [barcodeDict valueForKey:@"Barcode"];
    if([[barcodeDict valueForKey:@"isExist"] isEqualToString:@"YES"])
    {
        barcodeCell.barcode.textColor = [UIColor redColor];
        barcodeCell.alreadyExist.text = @"Already Exist";
    }
    else
    {
        barcodeCell.barcode.textColor = [UIColor whiteColor];
        barcodeCell.alreadyExist.text = @"";
    }
    // Delete barcode button
    (barcodeCell.deleteBarcode).tag = indexPath.row;
    [barcodeCell.deleteBarcode addTarget:self action:@selector(deleteBarcodeClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    barcodeCell.contentView.backgroundColor = [UIColor clearColor];
    barcodeCell.backgroundColor = [UIColor clearColor];
    
    return barcodeCell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - barcode Validation -

- (NSString *)generateRendomUPCUsingUUID
{
    NSString *strUIID = [NSUUID UUID].UUIDString;
    NSError *error = NULL;
    NSString *pattern = @"[a-zA-Z-]";
    NSRange range = NSMakeRange(0, strUIID.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *resultString = [regex stringByReplacingMatchesInString:strUIID  options:0  range:range withTemplate:@"$1"];
    NSInteger resultStringLength = resultString.length;
    if (resultStringLength >= 11) {
        resultString = [resultString substringToIndex:11];
    }
    else
    {
        NSInteger numberOfZero = 11 - resultStringLength;
        for (int i = 0; i < numberOfZero; i++) {
            resultString = [NSString stringWithFormat:@"0%@",resultString];
        }
    }
    resultString = [NSString stringWithFormat:@"4%@",resultString];
    return resultString;
}

-(void)addNewBarcode:(NSString *)strbarcode{
    if (strbarcode.length > 0) {
        NSString * strBarcodeType = [self getBarcodeTypeString];
        if (strbarcode.length > 48) {
            [self showMessage:@"Barcode is too long(only 48 characters allow in barcode)"];
            self.txtbarcodeText.text = @"";
            return;
        }
        else if ([self isBarcode:strbarcode Duplicatein:@[strBarcodeType]]) {
            [self showMessage:@"Barcode already exist in list"];
            self.txtbarcodeText.text = @"";
            return;
        }
        else{
            NSMutableArray * arrBarCodeTypes = [@[@"Single Item",@"Case",@"Pack"] mutableCopy];
            [arrBarCodeTypes removeObject:strBarcodeType];
            if (!self.isDuplicateBarcodeAllowed) {
                BOOL isDuplicate = FALSE;
                if ([self isBarcode:strbarcode Duplicatein:arrBarCodeTypes]) {
                    isDuplicate = TRUE;
                }
                if (isDuplicate) {
                    [self showMessage:@"Barcode already exist in list"];
                    self.txtbarcodeText.text = @"";
                    return;
                }
            }
        }
        [self addNewBarcodeInList:strbarcode];
    }
}

-(void)showMessage:(NSString *)strMessage{
    UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
    {};
    [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:strMessage buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
}

-(BOOL)isBarcode:(NSString *)strBarcode Duplicatein:(NSArray *)arrBarcodeType {
    NSPredicate *isBarcodePred;
    if (arrBarcodeType) {
        isBarcodePred = [NSPredicate predicateWithFormat:@"PackageType IN %@ AND Barcode == [cd]%@",arrBarcodeType,strBarcode];
    }
    else{
        isBarcodePred = [NSPredicate predicateWithFormat:@"Barcode == [cd]%@",strBarcode];
    }
    NSArray * duplicate = [self.arrItemBarcodeList filteredArrayUsingPredicate:isBarcodePred];
    return (duplicate.count > 0)?TRUE:FALSE;
}
-(void)addNewBarcodeInList:(NSString *)strBarcode {
    
    NSString *IsDefault = @"0";
    BOOL isAutoGeneratedUPC = FALSE;
    NSString * strBarcodeType = [self getBarcodeTypeString];
    if (self.segItemBarcodeType.selectedSegmentIndex == 0) {
        [self.arrItemBarcodeList setValue:@"0" forKey:@"IsDefault"];
        IsDefault = @"1";
    }
    else {
        if ([strBarcodeType isEqualToString:@"Case"]) {
            if ([self getItemBarcodeFromBarcodetype:@"Single Item"].count == 0) {
                IsDefault = @"1";
            }
        }
        if ([strBarcodeType isEqualToString:@"Pack"]) {
            if ([self getItemBarcodeFromBarcodetype:@"Single Item"].count == 0 && [self getItemBarcodeFromBarcodetype:@"Case"].count == 0) {
                IsDefault = @"1";
            }
        }
    }
    
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:strBarcode];
    BOOL isNumeric = [alphaNums isSupersetOfSet:inStringSet];
    if (isNumeric) // numeric
    {
        strBarcode = [self.rmsDbController trimmedBarcode:strBarcode];
    }
    
    if ([self.txtbarcodeText.text isEqualToString:lastAutoGeneratedUPC]) {
        isAutoGeneratedUPC = TRUE;
    }
    NSMutableDictionary *barcodeDict = [NSMutableDictionary dictionaryWithDictionary:@{@"Barcode":strBarcode,
                                                                                       @"PackageType":strBarcodeType,
                                                                                       @"IsDefault":IsDefault,
                                                                                       @"isExist":@"NO",
                                                                                       @"notAllowItemCode":@"",
                                                                                       @"IsUPCAutoGenerated":@(isAutoGeneratedUPC)                                                                                       }];
    [self.arrItemBarcodeList insertObject:barcodeDict atIndex:0];
    [self resettableFilterArray];
    lastAutoGeneratedUPC = @"";
    self.txtbarcodeText.text = @"";
}


#pragma mark - Scanner Device Type and Methods -
- (void)checkConnectedScannerType
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"] isEqualToString:@"Bluetooth"])
    {
        if (IsPad()) {
            [self.txtbarcodeText becomeFirstResponder];
        }
    }
    else
    {
        [self.txtbarcodeText resignFirstResponder];
    }
}

-(void)deviceButtonPressed:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"MultipleBarcode"])
        {
            isScannerUsed = TRUE;
            [status setString:@""];
        }
    }
}

-(void)deviceButtonReleased:(int)which
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        if([self.rimsController.scannerButtonCalled isEqualToString:@"MultipleBarcode"])
        {
            if(![status isEqualToString:@""])
            {
                [self textFieldShouldReturn:self.txtbarcodeText];
            }
        }
    }
}

-(void)barcodeData:(NSString *)barcode type:(int)type
{
    if ([(self.rmsDbController.globalScanDevice)[@"Type"]isEqualToString:@"Scanner"])
    {
        [status setString:@""];
        [status appendFormat:@"%@", barcode];
        self.txtbarcodeText.text = [self.rmsDbController trimmedBarcode:barcode];
    }
    else
    {
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action)
        {};
        [self.rmsDbController popupAlertFromVC:self title:@"Item Management" message:@"Please set scanner type as scanner" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}

@end
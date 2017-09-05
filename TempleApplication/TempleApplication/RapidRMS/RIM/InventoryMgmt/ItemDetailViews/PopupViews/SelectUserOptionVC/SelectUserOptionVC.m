//
//  SelectUserOptionVC.m
//  RapidRMS
//
//  Created by Siya9 on 05/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "SelectUserOptionVC.h"
#define HeaderFooterHeight 10 //need to changed in storyboard also

@interface SelectUserOptionVC () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UITableView * tblList;

//@property (nonatomic, strong) NSString * strTitle;
@property (nonatomic, strong) NSArray * arrListOption;
@property (nonatomic, strong) SelectionComplete selectionComplete;
@property (nonatomic, strong) SelectionColse selectionColse;


@end

@implementation SelectUserOptionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.fltRowHeight || self.fltRowHeight == 0) {
        self.fltRowHeight = 45.0f;
    }
    if (!self.intMiximumRowDisplay || self.intMiximumRowDisplay == 0) {
        self.intMiximumRowDisplay = 5;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    _lblTitle.text = _strTitle;
    if (!self.strkey) {
        self.strkey = @"name";
    }
    if (!self.strImgKey) {
        self.strImgKey = @"image";
    }
}

+(instancetype)setSelectionViewitem:(NSArray *)arrItem SelectionComplete:(SelectionComplete)selectionComplete SelectionColse:(SelectionColse)selectionColse {
    SelectUserOptionVC * instance = [SelectUserOptionVC getViewFromStoryBoard];
    
    instance.arrListOption = arrItem;
//    instance.strTitle = strTitle;
    instance.currentID = 0;
    instance.isMultipleSelection = false;
    instance.selectionComplete = selectionComplete;
    instance.selectionColse = selectionColse;
    return instance;
}

+(instancetype)setSelectionViewitem:(NSArray *)arrItem SelectedObject:(id)selectedobject SelectionComplete:(SelectionComplete)selectionComplete SelectionColse:(SelectionColse)selectionColse {
    SelectUserOptionVC * instance = [SelectUserOptionVC setSelectionViewitem:arrItem SelectionComplete:selectionComplete SelectionColse:selectionColse];
    instance.selectedObject = selectedobject;
    return instance;
}

+(instancetype)setSelectionViewitem:(NSArray *)arrItem OptionId:(NSNumber *)vid isMultipleSelectionAllow:(BOOL)isMultipale SelectionComplete:(SelectionComplete)selectionComplete SelectionColse:(SelectionColse)selectionColse {
    SelectUserOptionVC * instance = [SelectUserOptionVC getViewFromStoryBoard];
    
    instance.arrListOption = arrItem;
    instance.currentID = vid;
    instance.isMultipleSelection = isMultipale;
    instance.selectionComplete = selectionComplete;
    instance.selectionColse = selectionColse;
    return instance;
}

+(instancetype)getViewFromStoryBoard{
    return (SelectUserOptionVC *)[[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"SelectUserOptionVC_sid"];
}
#pragma mark - Table view data source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arrListOption.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.fltRowHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString * strOptionValue = @"";
    NSString * strCellIdentifier = @"cell";
    UIImage * imgImage = nil;
    if ([self.arrListOption[indexPath.row] isKindOfClass:[NSString class]]) {
        strOptionValue = self.arrListOption[indexPath.row];
        
    }
    else if ([self.arrListOption[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        strOptionValue = self.arrListOption[indexPath.row][self.strkey];
        if (self.arrListOption[indexPath.row][self.strImgKey]) {
            imgImage = [UIImage imageNamed:self.arrListOption[indexPath.row][self.strImgKey]];
        }
    }
    SelectUserOptionVCCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier forIndexPath:indexPath];
    
    cell.lblTitle.textColor = [UIColor whiteColor];
    cell.lblTitle.text = strOptionValue.uppercaseString;
    cell.imgCell.image = imgImage;
//    if (self.isMultipleSelection) {
//        cell.imgSelected.image = [UIImage imageNamed:@"radiobtn"];
//    }
    if (self.selectedObject) {
        if ([self.selectedObject isEqual:self.arrListOption[indexPath.row]]) {
            cell.lblTitle.textColor = [UIColor colorWithRed:1.000 green:0.624 blue:0.000 alpha:1.000];
//            if (self.isMultipleSelection) {
//                cell.imgSelected.image = [UIImage imageNamed:@"radioselected"];
//            }
        }
    }
    if ([self isNotSelectebleCellAtIndexPath:indexPath CellTitleText:cell.lblTitle.text]) {
        cell.lblTitle.textColor = [UIColor lightGrayColor];
        cell.userInteractionEnabled = FALSE;
    }
    else{
        cell.userInteractionEnabled = TRUE;
    }
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1) {
        cell.viewSeparator.hidden = TRUE;
    }
    else{
        cell.viewSeparator.hidden = FALSE;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}
-(BOOL)isNotSelectebleCellAtIndexPath:(NSIndexPath *)indexPath CellTitleText:(NSString *) strTitle{
    if (self.arrDisableSelectionObject && [self.arrDisableSelectionObject containsObject:self.arrListOption[indexPath.row]]) {
        return TRUE;
    }
    else if (self.arrDisableSelectionTitle && [self.arrDisableSelectionTitle containsObject:strTitle]) {
        return TRUE;
    }
    else {
        return FALSE;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isMultipleSelection) {
        
    }
    else {
        self.selectionComplete(@[self.arrListOption[indexPath.row]]);
        self.selectionColse(self);
    }
}

-(float)setHeightForView{
    float height = (_arrListOption.count*self.fltRowHeight)+(HeaderFooterHeight*2);

    if (height > (self.intMiximumRowDisplay*self.fltRowHeight)+(HeaderFooterHeight*2)+(self.fltRowHeight/2)) {
        height = (self.intMiximumRowDisplay*self.fltRowHeight)+(HeaderFooterHeight*2)+(self.fltRowHeight/2);
    }
    return height;
}

-(CGRect)getCenterFrameView:(UIView *)bgView{
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, [self setHeightForView]);
    frame.origin.x = (bgView.bounds.size.width - frame.size.width)/2;
    frame.origin.y = (bgView.bounds.size.height - frame.size.height)/2;
    
//    frame.origin.y = frame.origin.y - 50;
    return frame;
}

-(void)presentViewControllerForViewController:(UIViewController *)viewConteroler{
    CGRect frame = self.view.frame;
    frame.size.height = [self setHeightForView];
    if (CGSizeEqualToSize(CGSizeZero, self.sizePreferredContentSize)) {
        frame.size.width = self.sizePreferredContentSize.width;
    }
    self.sizePreferredContentSize = frame.size;
    [super presentViewControllerForViewController:viewConteroler];
}
/**
 *  present center in view
 *
 *  @param viewConteroler viewConteroler which display center
 *  @param view           coller button or view
 */
-(void)presentViewControllerForViewController:(UIViewController *)viewConteroler forSourceView:(UIView *)view{
    CGRect frame = self.view.frame;
    frame.size.height = [self setHeightForView];
    if (CGSizeEqualToSize(CGSizeZero, self.sizePreferredContentSize)) {
        frame.size.width = self.sizePreferredContentSize.width;
    }
    self.sizePreferredContentSize = frame.size;
    [super presentViewControllerForViewController:viewConteroler forSourceView:view];
}

/**
 *  display popup with arrow,it used for iphone and ipad
 *
 *  @param objView        viewConteroler which present
 *  @param sourceView     sourceView coller
 *  @param arrowDirection arrow Direction
 */
-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    
    CGRect frame = self.view.frame;
    frame.size.height = [self setHeightForView];
    if (!CGSizeEqualToSize(CGSizeZero, self.sizePreferredContentSize)) {
        frame.size.width = self.sizePreferredContentSize.width;
    }
    self.view.frame = frame;
    self.sizePreferredContentSize = frame.size;
    [super presentViewControllerForviewConteroller:objView sourceView:sourceView ArrowDirection:arrowDirection];
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    self.selectionColse(self);
}
@end


#pragma mark - Cell -
@implementation SelectUserOptionVCCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end

//
//  TagSuggestionViewController.m
//  RapidRMS
//
//  Created by Siya on 30/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "TagSuggestionVC.h"
#import "SizeMaster+Dictionary.h"
#import "SizeMaster.h"
#import "RmsDbController.h"
#import "RimsController.h"
#import "ItemInfoEditVC.h"

@interface TagSuggestionVC () <NSFetchedResultsControllerDelegate,UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *tagResultsController;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UITableView *tblTagList;

@end

@implementation TagSuggestionVC


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tblTagList)
    {
        NSArray *sections = self.tagResultsController.sections;
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[section];
        
        return sectionInfo.numberOfObjects;
    }
    else{
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagSuggestionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    SizeMaster *taglist = [self.tagResultsController objectAtIndexPath:indexPath];
    cell.lblTitle.text=taglist.sizeName;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
#pragma mark - Fetch All Group

- (NSFetchedResultsController *)tagResultsController {
    
    if (_tagResultsController != nil) {
    
        return _tagResultsController;
    }
    // Create and configure a fetch request with the GroupMaster entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SizeMaster" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    if (_strSearchTagText != nil && ![_strSearchTagText isEqualToString:@""]) {
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"sizeName CONTAINS[cd] %@", _strSearchTagText];
        fetchRequest.predicate = predicate;
    }
    
    // Create the sort descriptors array.
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sizeName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = @[aSortDescriptor];
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Create and initialize the fetch results controller.
    _tagResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    [_tagResultsController performFetch:nil];
    _tagResultsController.delegate = self;
    
    return _tagResultsController;
}

-(void)reloadTableWithSearchItem{
    
    _tagResultsController=nil;
    [_tblTagList reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SizeMaster *taglist = [self.tagResultsController objectAtIndexPath:indexPath];
    [self.tagSuggestionDelegate didSelectTagfromList:taglist.sizeName];
}
@end
#pragma mark - Cell -
@implementation TagSuggestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
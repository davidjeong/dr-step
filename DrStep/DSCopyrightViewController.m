//
//  DSCopyrightViewController.m
//  DrStep
//
//  Created by Juhwan Jeong on 3/21/16.
//
//

#import "DSCopyrightViewController.h"

#import "DSFrameworkTableViewCell.h"

@interface DSCopyrightViewController ()

@property (strong, nonatomic) NSArray *frameworks;

@end

@implementation DSCopyrightViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"framework" ofType:@"plist"];
    self.frameworks = [NSArray arrayWithContentsOfFile:path];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.frameworks.count;
}

static NSString *frameworkCellIdentifier = @"frameworkCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DSFrameworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:frameworkCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DSFrameworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:frameworkCellIdentifier];
    }
    
    NSDictionary *framework = [self.frameworks objectAtIndex:indexPath.row];
    cell.framework = framework[@"name"];
    cell.about = framework[@"about"];
    cell.license = framework[@"license"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static DSFrameworkTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:frameworkCellIdentifier];
    });
    
    cell.framework = [[self.frameworks objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.about = [[self.frameworks objectAtIndex:indexPath.row] objectForKey:@"about"];
    cell.license = [[self.frameworks objectAtIndex:indexPath.row] objectForKey:@"license"];
    
    
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

@end

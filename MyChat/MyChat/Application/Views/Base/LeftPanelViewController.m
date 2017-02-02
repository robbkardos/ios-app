//
//  LeftPanelViewController.m
//  DomumLink
//
//  Created by AnMac on 1/15/15.
//  Copyright (c) 2015 Petr. All rights reserved.
//

#import "LeftPanelViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SideMenuTableViewCell.h"
#import "MySidePanelController.h"

@interface LeftPanelViewController ()

@property (nonatomic, strong) NSMutableArray *menuPages;

@property (nonatomic, strong) IBOutlet UIView *containerView, *topView;

@end

@implementation LeftPanelViewController
@synthesize menuPages;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //menuPages = appController.menuPages;
    self.sidePanelController.slideDelegate = self;
    
    [self initView];
}

- (void)initView {


}

- (void)viewDidLayoutSubviews {
    
    CGRect containerFrame = self.containerView.frame;
    containerFrame.size.width = self.sidePanelController.leftVisibleWidth;
    [self.containerView setFrame:containerFrame];
    
    CGRect topFrame = self.topView.frame;
    [self.topView setFrame:CGRectMake(0, 0, containerFrame.size.width, topFrame.size.height)];
    
//    [self.menuTableView setFrame: CGRectMake(0, self.topView.frame.size.height, containerFrame.size.width, containerFrame.size.height - topFrame.size.height + (float)[menuPages count])];
    
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [menuPages count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height / (float)[menuPages count] - 1.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(SideMenuTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (SideMenuTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenuTableViewCell *cell = (SideMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"sideMenuCell"];
    
    NSMutableDictionary *dic = [menuPages objectAtIndex:indexPath.row];
    
    [cell setTag:[[dic objectForKey:@"tag"] intValue]];
    [cell.titleLabel setText: [dic objectForKey:@"title"]];
    
    NSString *icon = [dic objectForKey:@"icon"];
    if([appController.currentMenuTag isEqualToString:[dic objectForKey:@"tag"]]) {
        icon = [icon stringByAppendingString:@"_over"];
        [cell.bgLabel setBackgroundColor:RGBA(41, 43, 47, 1)];
    } else {
        [cell.bgLabel setBackgroundColor:RGBA(44, 48, 52, 1)];
    }
    [cell.iconImageView setImage:[UIImage imageNamed:icon]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Page Transition

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SideMenuTableViewCell *cell = (SideMenuTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    appController.currentMenuTag = [[menuPages objectAtIndex:indexPath.row] objectForKey:@"tag"];
    [tableView reloadData];
//    
//    WFMainViewController *mainViewController;
//    WFSettingsViewController *settingsViewController;
//    WFMyBarksViewController *myBarksViewController;
//    WFLikedBarksViewController *likedBarksViewController;
//    WFFavoriteBarkersViewController *favoriteBarkersViewController;
//    
//    UINavigationController *navController;
//    
//    switch (cell.tag) {
//        case 1:
//            mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainPage"];
//            navController = [[UINavigationController alloc] initWithRootViewController: mainViewController];
//            self.sidePanelController.centerPanel = navController;
//            break;
//        case 2:
//            myBarksViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"myBarksPage"];
//            navController = [[UINavigationController alloc] initWithRootViewController: myBarksViewController];
//            self.sidePanelController.centerPanel = navController;
//            break;
//        case 3:
//            likedBarksViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"likedBarksPage"];
//            navController = [[UINavigationController alloc] initWithRootViewController: likedBarksViewController];
//            self.sidePanelController.centerPanel = navController;
//            break;
//        case 4:
//            favoriteBarkersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"favoriteBarkersPage"];
//            navController = [[UINavigationController alloc] initWithRootViewController: favoriteBarkersViewController];
//            self.sidePanelController.centerPanel = navController;
//            break;
//        case 5:
//            settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsPage"];
//            navController = [[UINavigationController alloc] initWithRootViewController: settingsViewController];
//            self.sidePanelController.centerPanel = navController;
//            break;
//        case 6:
//            [self defaultShare];
//            break;
//        default:
//            break;
//    }
    
}

#pragma mark -  Left Side Menu Show

- (void)onMenuShow {
    if([commonUtils getUserDefault:@"is_my_profile_changed"]) {
        [commonUtils removeUserDefault:@"is_my_profile_changed"];
        [self initView];
    }
}
- (void)onMenuHide {

}

@end


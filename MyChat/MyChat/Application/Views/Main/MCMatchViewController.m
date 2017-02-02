//
//  MCMatchViewController.m
//  MyChat
//
//  Created by New Star on 3/1/16.
//  Copyright © 2016 NewMobileStar. All rights reserved.
//

#import "MCMatchViewController.h"
#import "MCMatchCollectionViewCell.h"
#import "MCPreviewChatViewController.h"

@interface MCMatchViewController () <UICollectionViewDataSource, UICollectionViewDelegate>{
    
    NSInteger segmentIndex;
    NSMutableArray *userArray;
    
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MCMatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    segmentIndex = 0;
    [_segmentControl setSelectedSegmentIndex:segmentIndex];
    
    userArray = [[NSMutableArray alloc] init];

    NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] init];
    NSString *genderStr;
    for (int i = 0; i < [appController.allUser count]; i++) {
        tempUser = [appController.allUser objectAtIndex:i];
        genderStr = [tempUser objectForKey:@"user_gender"];
        if ([genderStr isEqualToString:@"1"]) {
            [userArray addObject:tempUser];
        }
    }
    
    [self initUI];
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [_collectionView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initUI{
    
    int kCellsPerRow = 3;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    
    CGFloat availableWidthForCells = CGRectGetWidth(_collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow - 1);
    CGFloat cellWidth = availableWidthForCells / kCellsPerRow;
    
    flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth + 5);
}

#pragma mark - Segement Control Event

- (IBAction)onSegementValueChanged:(UISegmentedControl *)sender {
   
    segmentIndex = sender.selectedSegmentIndex;
    NSString *genderStr;
    NSMutableDictionary *tempUser = [[NSMutableDictionary alloc] init];
    
    switch (segmentIndex) {
        case 0:
            userArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [appController.allUser count]; i++) {
                tempUser = [appController.allUser objectAtIndex:i];
                genderStr = [tempUser objectForKey:@"user_gender"];
                if ([genderStr isEqualToString:@"1"]) {
                    [userArray addObject:tempUser];
                }
            }
            break;
            
        case 1:
            userArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [appController.allUser count]; i++) {
                tempUser = [appController.allUser objectAtIndex:i];
                genderStr = [tempUser objectForKey:@"user_gender"];
                if ([genderStr isEqualToString:@"2"]) {
                    [userArray addObject:tempUser];
                }
            }
            break;
            
        default:
            break;
    }
    
    [self.collectionView reloadData];
    
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [userArray count];
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"matchsCollectionViewCell";
    
    MCMatchCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    
   
    NSString *strGender =[[userArray objectAtIndex:indexPath.item] objectForKey:@"user_gender"];
    
    UIImage *tempImage;
    if ([strGender isEqualToString:@"1"]) {
        tempImage = [UIImage imageNamed:@"user_avatar_male"];
    }else{
        tempImage = [UIImage imageNamed:@"user_avatar_female"];
    }
    
    [commonUtils setImageViewAFNetworking:cell.matchesPhotoView withImageUrl:[[userArray objectAtIndex:indexPath.item] objectForKey:@"user_profilephoto_url"] withPlaceholderImage:tempImage];
    
    
    //Get Current Age
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYearStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"%@", currentYearStr);
    
    NSInteger currentYear = [[currentYearStr stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
    
    NSInteger birthdayYear = 2016;
    
    if([commonUtils checkKeyInDic:@"user_birthday" inDic:[[userArray objectAtIndex:indexPath.item] mutableCopy]]) {
        
        NSString *string = [[userArray objectAtIndex:indexPath.item] objectForKey:@"user_birthday"];
        if (string.length == 10) {
            NSString *birthdaySring = [[userArray objectAtIndex:indexPath.item] objectForKey:@"user_birthday"];
            NSArray  *birthdayArray = [birthdaySring componentsSeparatedByString:@"/"];
            birthdayYear = [[birthdayArray[2] stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
        }
    }
    
    
    NSString *age = [NSString stringWithFormat:@"%ld", currentYear - birthdayYear];
    
    NSString *matchUserNameAgeStr = [NSString stringWithFormat:@"%@ | %@", [[userArray objectAtIndex:indexPath.item] objectForKey:@"user_firstname"], age];
    cell.matchesNameAgeLabel.text = matchUserNameAgeStr;

       
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    appController.chatUser = [userArray objectAtIndex:indexPath.item];
    
    MCPreviewChatViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"previewMatchPage"];
    [self.navigationController pushViewController:pageController animated:YES];
    
}

- (IBAction)onClickBackBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

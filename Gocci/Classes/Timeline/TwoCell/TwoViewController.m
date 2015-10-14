//
//  TwoViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/14.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "TwoViewController.h"
#import "TwoViewCell.h"

@interface TwoViewController ()

@end

@implementation TwoViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
}


static NSString * const reuseIdentifier = @"Cell";
static const CGFloat kCellMargin = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)setupData
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 取得したデータを self.posts に格納
    thumb = [NSMutableArray arrayWithCapacity:0];
    postid_ = [NSMutableArray arrayWithCapacity:0];
    restname = [NSMutableArray arrayWithCapacity:0];
    
    NSArray* items = (NSArray*)_receiveDic2;
    
    for (NSDictionary *post in items) {
        
        NSDictionary *thumbGet = [post objectForKey:@"thumbnail"];
        [thumb addObject:thumbGet];
        NSDictionary *postidGet = [post objectForKey:@"post_id"];
        [postid_ addObject:postidGet];
        NSDictionary *restnameGet = [post objectForKey:@"restname"];
        [restname addObject:restnameGet];
    }
    
    NSLog(@"thumb:%@,id:%@,restname:%@",thumb,postid_,restname);
    if ([thumb count] == 0) {
        // 画像表示例文
        UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGSize boundsSize = self.view.bounds.size;
        iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
        [self.view addSubview:iv];
    }else{
        [self.collectionView reloadData];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_receiveDic2 count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    TwoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
                      placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    cell.title.text = restname[indexPath.row];
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"postid:%@",postid_[indexPath.row]);
   
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, kCellMargin, kCellMargin, kCellMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    CGFloat length = (CGRectGetWidth(self.view.frame) / 2) - (kCellMargin * 2);
    if (isPad) {
        // fixed size for iPad in landscape and portrait
        length = 256 - (kCellMargin * 2);
    }
    return CGSizeMake(length, length);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

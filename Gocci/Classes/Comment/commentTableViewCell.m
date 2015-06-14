//
//  commentTableViewCell.m
//  Gocci
//
//  Created by デザミ on 2015/06/13.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "commentTableViewCell.h"

#import "Sample4TableViewCell.h"
#import "UIImageView+WebCache.h"


NSString * const CommentCellIdentifier = @"commentTableViewCell";
//NSString * const CommentAllCellIdentifier = @"commentAllTableViewCell";

//static BOOL isCommentTableViewCellAll = NO;

@interface commentTableViewCell()
{
	BOOL isCommentTableViewCellAll;
}
@property(nonatomic,retain) NSMutableArray *listUsername;
@property(nonatomic,retain) NSMutableArray *listProfileImg;
@property(nonatomic,retain) NSMutableArray *listComment;
@property(nonatomic,retain) NSMutableArray *listDate;

@property (weak, nonatomic) IBOutlet UIButton *buttonMoreComment;
@property (weak, nonatomic) IBOutlet UITableView *tableviewComment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintTableviewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintTableviewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintTop;

@end


@implementation commentTableViewCell

- (void)awakeFromNib {
    // Initialization code
	
	self.tableviewComment.delegate = self;
	self.tableviewComment.dataSource = self;
	self.tableviewComment.separatorColor = [UIColor clearColor];
	
//	[self.buttonMoreComment setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action
#pragma mark 読み込むボタン
- (IBAction)onMoreComment:(id)sender {
	
	isCommentTableViewCellAll = YES;
	
	//tableviewを全体に
	
	self.buttonMoreComment.hidden = YES;
	self.tableviewComment.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	self.layoutConstraintTop.constant = 0;
	
	
	[self.tableviewComment reloadData];
}

#pragma mark - 反映
-(void)configureWithArray:(NSArray*)commentlist
{
	/*
	 [0]
	 {
	 "comment_user_id": "209",
	 "username": "kazu0914",
	 "profile_img": "http://api-gocci.jp/img/6.png",
	 "comment": "高級感漂ってる！",
	 "comment_date": "2015-05-23 22:02:43"
	 },
	*/
	
	self.listUsername = [[NSMutableArray alloc] init];
	self.listProfileImg = [[NSMutableArray alloc] init];
	self.listComment = [[NSMutableArray alloc] init];
	self.listDate = [[NSMutableArray alloc] init];
	
	//新しい順から古い順へ
	NSInteger count = [commentlist count];
	for (NSInteger i = count - 1; i >= 0; i--) {
		NSDictionary *dict = [commentlist objectAtIndex:i];
		
		// ユーザー名
		NSString *username = [dict objectForKey:@"username"];
		[self.listUsername addObject:username];
		
		// プロフ画像URL
		NSString *picture = [dict objectForKey:@"profile_img"];
		[self.listProfileImg addObject:picture];
		
		//コメント内容
		NSString *comment = [dict objectForKey:@"comment"];
		[self.listComment addObject:comment];
		
		//日付
		NSString *date_str = [dict objectForKey:@"comment_date"];
		[self.listDate addObject:date_str];
	}
	
//	for (NSDictionary *dict in commentlist) {
//		// ユーザー名
//		NSString *username = [dict objectForKey:@"username"];
//		[self.listUsername addObject:username];
//		
//		// プロフ画像URL
//		NSString *picture = [dict objectForKey:@"profile_img"];
//		[self.listProfileImg addObject:picture];
//
//		//コメント内容
//		NSString *comment = [dict objectForKey:@"comment"];
//		[self.listComment addObject:comment];
//		
//		//日付
//		NSString *date_str = [dict objectForKey:@"comment_date"];
//		[self.listDate addObject:date_str];
//	}
	
	isCommentTableViewCellAll = NO;

	
//	NSInteger count_comment = [self.listUsername count];
//	NSString *title_btn = [NSString stringWithFormat:@"%ld件のコメントを読み込む",(long)count_comment];
//	[self.buttonMoreComment setTitle:title_btn forState:UIControlStateNormal];
}

#pragma mark - UItableViewData
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = [self.listUsername count];
	if (!isCommentTableViewCellAll) {
		if (count > 3) count = 3;
	}
	
	return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [Sample4TableViewCell heightCell];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row_index = indexPath.row;
	
	Sample4TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sample4TableViewCell"];
	if (!cell) {
		cell = [Sample4TableViewCell cell];
	}
	
	NSInteger index_now = row_index;
	
	//セル内
	if (!isCommentTableViewCellAll) {
		//最初の３件まで表示の場合
		//データ数
		NSInteger count_data = [self.listUsername count];
		//最初のインデックス
		NSInteger index_first = count_data - 3;
		//データ数が３件未満なら
		if (index_first < 0) {
			index_first = 0;
		}
		//読み込むインデックス
		index_now = index_first + row_index;
	}
	//全表示の場合
	//ユーザー名
	if ([self.listUsername objectAtIndex:index_now]) {
		cell.UsersName.text = [self.listUsername objectAtIndex:index_now];
	}
	
	if([self.listProfileImg objectAtIndex:index_now]) {
		//ユーザーの画像を取得
		NSString *dottext = [self.listProfileImg objectAtIndex:index_now];
		// Here we use the new provided setImageWithURL: method to load the web image
		
		[cell.UsersPicture sd_setImageWithURL:[NSURL URLWithString:dottext]
							 placeholderImage:[UIImage imageNamed:@"default.png"]
									  options:0
									 progress:nil
									completed:nil
		 ];
	}
	
	//コメント
	if ([self.listComment objectAtIndex:index_now]) {
		cell.Comment.text = [self.listComment objectAtIndex:index_now];
	}
	
	//日付
	if ([self.listDate objectAtIndex:index_now]) {
		cell.DateOfComment.text = [self.listDate objectAtIndex:index_now];
	}
	
	return cell;
}

#pragma mark - Value
+(CGFloat)heightCell
{
	commentTableViewCell *cell = [commentTableViewCell cell];

	CGFloat height = cell.frame.size.height;
	
	return height;
}

#pragma mark - Initialize
+ (instancetype)cell
{
	return [[NSBundle mainBundle] loadNibNamed:CommentCellIdentifier owner:self options:nil][0];
}

//+ (instancetype)cell2
//{
//	return [[NSBundle mainBundle] loadNibNamed:CommentAllCellIdentifier owner:self options:nil][0];
//}

@end

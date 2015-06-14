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

@interface commentTableViewCell()
{
	BOOL isAllComment;
}
@property(nonatomic,retain) NSMutableArray *listUsername;
@property(nonatomic,retain) NSMutableArray *listProfileImg;
@property(nonatomic,retain) NSMutableArray *listComment;
@property(nonatomic,retain) NSMutableArray *listDate;

@property (weak, nonatomic) IBOutlet UIButton *buttonMoreComment;
@property (weak, nonatomic) IBOutlet UITableView *tableviewComment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintView;


@end


@implementation commentTableViewCell

- (void)awakeFromNib {
    // Initialization code
	
	self.tableviewComment.delegate = self;
	self.tableviewComment.dataSource = self;
	self.tableviewComment.separatorColor = [UIColor clearColor];
	
	[self.buttonMoreComment setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action
- (IBAction)onMoreComment:(id)sender {
	
	isAllComment = YES;
	
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
	
	for (NSDictionary *dict in commentlist) {
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
	
	isAllComment = NO;
	
	NSInteger count_comment = [self.listUsername count];
	NSString *title_btn = [NSString stringWithFormat:@"%ld件のコメントを読み込む",(long)count_comment];
	[self.buttonMoreComment setTitle:title_btn forState:UIControlStateNormal];
}

#pragma mark - UItableViewData
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = [self.listUsername count];
	if (!isAllComment) {
		count = 3;
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
	
	//セル内
	//ユーザーも名
	if ([self.listUsername objectAtIndex:row_index]) {
		cell.UsersName.text = [self.listUsername objectAtIndex:row_index];
	}
	
	if([self.listProfileImg objectAtIndex:row_index]) {
		//ユーザーの画像を取得
		NSString *dottext = [self.listProfileImg objectAtIndex:row_index];
		// Here we use the new provided setImageWithURL: method to load the web image
		
		[cell.UsersPicture sd_setImageWithURL:[NSURL URLWithString:dottext]
							 placeholderImage:[UIImage imageNamed:@"default.png"]
									  options:0
									 progress:nil
									completed:nil
		 ];
	}
	//cell.UsersPicture.image = nil;
	
	//コメント
	if ([self.listComment objectAtIndex:row_index]) {
		cell.Comment.text = [self.listComment objectAtIndex:row_index];
	}
	
	//日付
	if ([self.listDate objectAtIndex:row_index]) {
		cell.DateOfComment.text = [self.listDate objectAtIndex:row_index];
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

@end

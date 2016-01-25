

#import "DropDownListView.h"
#import "UIColor+hex.h"
#import "ContentsConstant.h"
//#import "ConstForQuoteAndOrder.h"
#define TOUCH_VIEW_TAG 10000

@implementation DropDownListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate backColor: (NSString *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        currentExtendSection = -1;
        self.dropDownDataSource = datasource;
        self.dropDownDelegate = delegate;
        NSInteger sectionNum =0;
        if ([self.dropDownDataSource respondsToSelector:@selector(numberOfSections)] ) {
            
            sectionNum = [self.dropDownDataSource numberOfSections];
        }
        
        if (sectionNum == 0) {
            self = nil;
        }
        
//        //最初のview
//        int buttonHeight = 20*SIZE;
//        CGFloat sectionWidth = (1.0*(frame.size.width - (sectionNum - 1)*SPACE_BUTTON)/sectionNum);
//        for (int i = 0; i <sectionNum; i++) {
//            UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionWidth*i+i*SPACE_BUTTON, (self.frame.size.height - buttonHeight)/2, sectionWidth, buttonHeight)];
//            sectionBtn.tag = SECTION_BTN_TAG_BEGIN + i;
////            sectionBtn.backgroundColor = [UIColor colorWithHexString:LEFT_RATE_BG];
//            
//            if([color isEqualToString:@"white"]){
//                [sectionBtn setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_white.png"] forState:UIControlStateNormal];
//            }
//            else{
//                [sectionBtn setBackgroundImage:[UIImage imageNamed:@"button_combobox_roundedcorners_blue.png"] forState:UIControlStateNormal];
//            }
//            
//
//            [sectionBtn addTarget:self action:@selector(sectionBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
//            NSString *sectionBtnTitle = @"--";
//            if ([self.dropDownDataSource respondsToSelector:@selector(titleInSection:index:)]) {
//                sectionBtnTitle = [self.dropDownDataSource titleInSection:i index:[self.dropDownDataSource defaultShowSection:i]];
//            }
//            [sectionBtn  setTitle:sectionBtnTitle forState:UIControlStateNormal];
//            sectionBtn.titleLabel.numberOfLines = 0;
//            sectionBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//            sectionBtn.titleLabel.lineBreakMode = 0;
//            sectionBtn.layer.cornerRadius = RADIOUS_5;
//            [sectionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            sectionBtn.titleLabel.font = [UIFont systemFontOfSize:FONT_10];
//            [self addSubview:sectionBtn];
//            [self.mSuperView bringSubviewToFront:sectionBtn];
//            
////            int arrowSize = 6*SIZE;
////            UIImageView *sectionBtnIv = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth - arrowSize - 2, (sectionBtn.frame.size.height-arrowSize)/2, arrowSize, arrowSize)];
//////            [sectionBtnIv setImage:[UIImage imageNamed:@"down_dark.png"]];
////            [sectionBtnIv setContentMode:UIViewContentModeScaleToFill];
////            sectionBtnIv.tag = SECTION_IV_TAG_BEGIN + i;
////            sectionBtnIv.transform = CGAffineTransformRotate(sectionBtnIv.transform, DEGREES_TO_RADIANS(180));
////            [sectionBtn addSubview: sectionBtnIv];
//        
//        }
        
    }
    return self;
}

-(void)sectionBtnTouch:(UIButton *)btn
{
    NSInteger section = btn.tag - SECTION_BTN_TAG_BEGIN;
    if ([self isShow]){
        [self hideExtendedChooseView];
    }else{
        currentExtendSection = section;
        [self showChooseListViewInSection:currentExtendSection choosedIndex:[self.dropDownDataSource defaultShowSection:currentExtendSection]];
//        [self tranformArrow];
    }
}
//-(void)tranformArrow{
//    UIImageView *currentIV= (UIImageView *)[self viewWithTag:(SECTION_IV_TAG_BEGIN + currentExtendSection)];
//    [UIView animateWithDuration:0.3 animations:^{
//        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
//    }];
//}

- (void)setTitle:(NSString *)title inSection:(NSInteger) section
{
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +section];
    [btn setTitle:title forState:UIControlStateNormal];
}
- (BOOL)isShow
{
    if (currentExtendSection == -1) {
        return NO;
    }
    return YES;
}
-  (void)hideExtendedChooseView
{
//    [self tranformArrow];
    currentExtendSection = -1;
    CGRect rect = self.mTableView.frame;
    rect.origin.y = self.buttonView.frame.origin.y;
    [UIView animateWithDuration:0.3  delay:0.05 options:0 animations:^{
        self.mTableView.alpha = 0.0f;
        self.mTableView.frame = rect;
    }completion:^(BOOL finished){
        [self.mTableView removeFromSuperview];
    }];
}

-(void)showChooseListViewInSection:(NSInteger)section choosedIndex:(NSInteger)index
{
    int sectionWidth = (self.frame.size.width - ([self.dropDownDataSource numberOfSections] -1)*SPACE_BUTTON)/[self.dropDownDataSource numberOfSections];
    NSUInteger numberRows = [self.dropDownDataSource numberOfRowsInSection:currentExtendSection];
    if (!self.mTableView) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideExtendedChooseView)];
        tapGestureRecognizer.delegate = self;
        [self.mSuperView addGestureRecognizer:tapGestureRecognizer];
        
        self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x + sectionWidth *section + SPACE_BUTTON*section, self.buttonView.frame.origin.y, sectionWidth, numberRows*TABLE_CELL_HEIGHT) style:UITableViewStylePlain];
//        self.mTableView.backgroundColor = [UIColor colorWithHexString:LEFT_RATE_BG];
        self.mTableView.dataSource = self;
        self.mTableView.delegate = self;
        self.mTableView.alpha = 0.0;
        if ([self.mTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.mTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self.mTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.mTableView setLayoutMargins:UIEdgeInsetsZero];
        }
    }
  
    //tableviewのframe
    CGRect rect = self.mTableView.frame;
    rect.origin.x = self.frame.origin.x + sectionWidth *section + SPACE_BUTTON*section;
    rect.size.height = numberRows*TABLE_CELL_HEIGHT;
    self.mTableView.frame = rect;
    [self.mSuperView addSubview:self.mTableView];
    [self.mTableView reloadData];
    //動画位置
    rect.origin.y = self.buttonView.frame.origin.y - rect.size.height + (self.frame.size.height - CELL_HEIGHT)/2;//TABLE_VIEW_HEIGHT;
    [UIView animateWithDuration:0.3 delay:0.05 options:0 animations:^{
        self.mTableView.alpha = 1.0;
        self.mTableView.frame =  rect;
    } completion:^(BOOL finished){
    }];
    
}

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
    UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
    if(self.editJuge) {
        if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
            [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
            [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
            [self hideExtendedChooseView];
        }
    }else{
        if(currentExtendSection == 0){
            [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
            [self hideExtendedChooseView];
        }else{
            [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
            [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
            [self hideExtendedChooseView];
        }
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark -- UITableView DataSource


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropDownDataSource numberOfRowsInSection:currentExtendSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
//    cell.backgroundColor = [UIColor colorWithHexString:LEFT_RATE_BG]; //26 99 166
    cell.backgroundColor = [UIColor colorWithRed:26/255.0 green:99/255.0 blue:166/255.0 alpha:1.0];
    int sectionWidth = (self.frame.size.width - ([self.dropDownDataSource numberOfSections] -1)*SPACE_BUTTON)/[self.dropDownDataSource numberOfSections];
    UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sectionWidth, TABLE_CELL_HEIGHT)];
    menuLabel.text = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
    menuLabel.font = [UIFont systemFontOfSize:FONT_10];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
    if ([currentSectionBtn.titleLabel.text isEqualToString:menuLabel.text]) {
        menuLabel.textColor = [UIColor whiteColor];
    }else{
        if(self.editJuge) {
            menuLabel.textColor = [UIColor blackColor];
        }else{
            if(currentExtendSection == 0){
                menuLabel.textColor = [UIColor grayColor];
            }else{
                menuLabel.textColor = [UIColor blackColor];
            }
        }
    }
    menuLabel.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:menuLabel];
    // tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // tableView.separatorColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.tag = TOUCH_VIEW_TAG;
    return cell;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(touch.view.tag == TOUCH_VIEW_TAG) {
        return NO;
    }else{
        return YES;
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

//
//  DropDownListView.h
//  DropDownDemo
//
//  Created by ias_sec on 2015/11/04.
//  Copyright © 2015年 TnsStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownChooseProtocol.h"

@interface DropDownListView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    NSInteger currentExtendSection;     //今展開してるsection ，最初は－1，展開してない
}

@property (nonatomic, assign) id<DropDownChooseDelegate> dropDownDelegate;
@property (nonatomic, assign) id<DropDownChooseDataSource> dropDownDataSource;

@property (nonatomic, strong) UIView *mSuperView;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIView *mTableBaseView;
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, assign) BOOL editJuge;

- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate backColor: (NSString *)color;
- (void)setTitle:(NSString *)title inSection:(NSInteger) section;

- (BOOL)isShow;
- (void)hideExtendedChooseView;

@end

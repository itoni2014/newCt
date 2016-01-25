//
//  ChartView.h
//  livestarS2
//
//  Created by ias_sec on 2015/11/11.
//  Copyright © 2015年 ias_sec. All rights reserved.
//
#import <UIKit/UIKit.h>

//#import "DropDownChooseProtocol.h"
//#import "ListSelectProtocol.h"


@interface ChartView : UIView <UITableViewDelegate>



@property (strong, nonatomic) UIButton *ashiSelectButton;

- (void)saveTechnicalSettings;

- (void)updateCharts;

@end

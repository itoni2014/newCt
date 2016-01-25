#import <UIKit/UIKit.h>

@interface DetailChartView :  UIView


@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIButton *ashiButton;


@property CGFloat chartWidth;
@property CGFloat scrollContentWidth;
@property CGFloat chartHeight;
@property CGFloat subchartHeight;
@property CGFloat datetimeHeight;
@property CGFloat subChartStartY;
@property CGFloat subChartValidHeight;

@property (strong, nonatomic) UIButton *settingButton;



@end

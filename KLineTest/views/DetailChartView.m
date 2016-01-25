

#import "DetailChartView.h"
#import "ChartSettingView.h"
#import "ChartBox.h"
#import "OhlcBean.h"
#import "DetailChartMainView.h"
#import "DetailChartSubView.h"
#import "DetailChartDatetimeView.h"
#import "DetailChartCandlestickView.h"
#import "ChartMovAvgView.h"
#import "ChartBollingerView.h"
#import "ChartIchimokuView.h"
#import "ChartRsiView.h"
#import "ChartMacdView.h"
#import "ChartStochasView.h"
#import "ChartVolumeView.h"
#import "FourPricesView.h"
#import "ChartNamesView.h"
#import "SubChartNamesView.h"
//#import "DropDownListView.h"

@interface DetailChartView()<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
}
@end

@implementation DetailChartView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];


    }
    
    return self;
}


@end

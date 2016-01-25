
#import <UIKit/UIKit.h>

//#import "DropDownChooseProtocol.h"
//#import "ListSelectProtocol.h"


@interface ChartView : UIView <UITableViewDelegate>



@property (strong, nonatomic) UIButton *ashiSelectButton;

- (void)saveTechnicalSettings;

- (void)updateCharts;

@end

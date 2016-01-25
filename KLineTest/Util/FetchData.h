#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ChartBox.h"

@interface FetchData : NSObject

@property (nonatomic,retain) NSMutableArray *resultMutableArray;
@property (nonatomic,retain) NSArray *dayDatas;
//@property (nonatomic,retain) NSMutableArray *category;
//@property (nonatomic,retain) NSString *lastTime;
//@property (nonatomic,retain) UILabel *status;
@property (nonatomic,assign) BOOL isFinish;
//@property (nonatomic,assign) CGFloat maxValue;
//@property (nonatomic,assign) CGFloat minValue;
//@property (nonatomic,assign) CGFloat volMaxValue;
//@property (nonatomic,assign) CGFloat volMinValue;
//@property (nonatomic,assign) NSInteger kCount;
//@property (nonatomic,retain) NSString *req_type;

-(id)initWithUrl:(NSString*)url;

@end

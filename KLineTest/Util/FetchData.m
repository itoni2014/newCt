#import "FetchData.h"
//#import "ASIHTTPRequest.h"
#import "OhlcBean.h"

@implementation FetchData

-(id)init{
    self = [super init];
    if (self){
        self.isFinish = NO;
//        self.maxValue = 0;
//        self.minValue = CGFLOAT_MAX;
//        self.volMaxValue = 0;
//        self.volMinValue = CGFLOAT_MAX;
    }
    return  self;
}

-(id)initWithUrl:(NSString *)url{
    if (self){
        
        // キャッシュしたデータを取得
        NSArray *tempArray = (NSArray *)[ChartBox getUserDefaults:@"daydatas"];
        if (tempArray.count > 0) {
            self.dayDatas = tempArray;
        }
        
        NSArray *lines = (NSArray *)[ChartBox getUserDefaults:[ChartBox md5HexDigest:url]];
        if (lines.count > 0) {
            [self changeData:lines];
        }
        else{
//            NSLog(@"url: %@",url);
//            NSURL *nurl = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:nurl];
//            [request setTimeOutSeconds:30];
//            [request setCachePolicy:ASIUseDefaultCachePolicy];
//            [request startSynchronous];
//            
//            [self Finished:request];
            
            
        }
    }
    return self;
}

//- (void)Finished:(ASIHTTPRequest *)request{
//    
////    self.status.text = @"";
//    NSString *content = [request responseString];
//    //    NSLog(@"%@", content);
//    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
////    if ([self.req_type isEqualToString:@"d"]) {
////        self.dayDatas = lines;
////        [ChartBox setUserDefaults:lines forKey:@"daydatas"];
////    }
//    [ChartBox setUserDefaults:lines forKey:[ChartBox md5HexDigest:[[NSString alloc] initWithFormat:@"%@",request.url]]];
//    [self changeData:lines];
//    request = nil;
//    self.isFinish = YES;
//    
//}

-(void)changeData:(NSArray *)lines{
    
    if(self.resultMutableArray == nil){
        self.resultMutableArray = [[NSMutableArray alloc] init];
    }
    [self.resultMutableArray removeAllObjects];

    NSInteger cnt;
    if ( lines.count > CANDLESTICK_COUNT_ALL ) {
        cnt = CANDLESTICK_COUNT_ALL;
    }
    else{
        cnt = lines.count;
    }
    
    if(cnt < 400){
        cnt--;
    }
    
    
    for (NSInteger idx = 1; idx <= cnt; idx++) {
        NSString *line = [lines objectAtIndex:idx];
        if([line isEqualToString:@""]){
            continue;
        }
//        if([ lines indexOfObject:line ] == 0){
//            continue;
//        }
        
        
        NSArray *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        if([self getOhlcBean:arr] != nil){
            [self.resultMutableArray addObject:[self getOhlcBean:arr]];
        }
    }
    
//    NSLog(@"取って来た件数:[%d]　取得件数:[%ld] 可変LIST件数:[%ld] ", (int)lines.count, cnt, self.resultMutableArray.count );

}

- (OhlcBean *)getOhlcBean:(NSArray *)item{
    if(item == nil || item.count < 6 ){
        return nil;
    }
    
    OhlcBean *bean = [[OhlcBean alloc]init];
    bean.openPrice = [[NSDecimalNumber alloc] initWithString: item[1]];
    bean.highPrice = [[NSDecimalNumber alloc] initWithString: item[2]];
    bean.lowPrice = [[NSDecimalNumber alloc] initWithString: item[3]];
    bean.closePrice = [[NSDecimalNumber alloc] initWithString: item[4]];
    bean.turnover = [item[5] integerValue];
    bean.fourValuesDate = item[0];
    
    return bean;
}


//-(CGFloat)sumArrayWithData:(NSArray*)data andRange:(NSRange)range{
//    CGFloat value = 0;
//    if (data.count - range.location>range.length) {
//        NSArray *newArray = [data objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:range]];
//        for (NSString *item in newArray) {
//            NSArray *arr = [item componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
//            value += [[arr objectAtIndex:4] floatValue];
//        }
//        if (value>0) {
//            value = value / newArray.count;
//        }
//    }
//    return value;
//}

//- (void)Failed:(ASIHTTPRequest *)request{
////    self.status.text = @"Error!";
//    request = nil;
//    self.isFinish = YES;
//}

-(void)dealloc{
    
}

@end

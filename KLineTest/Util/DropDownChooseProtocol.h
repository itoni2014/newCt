//
//  DropDownChooseProtocol.h
//  DropDownDemo
//
//  Created by ias_sec on 2015/11/04.
//  Copyright © 2015年 TnsStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DropDownChooseDelegate <NSObject>

@optional

-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index;
@end

@protocol DropDownChooseDataSource <NSObject>
-(NSInteger)numberOfSections;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index;
-(NSInteger)defaultShowSection:(NSInteger)section;

@end




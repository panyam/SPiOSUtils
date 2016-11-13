//
//  SPMUBaseTableVC.h
//  SangeethaPriya
//
//  Created by Sri Panyam on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMUBaseVC.h"

typedef UITableViewCell *(^SPMUTableCellMaker)(UITableView *tableView, NSIndexPath *indexPath, id cellData);

@interface SPMUBaseTableVC : SPMUBaseVC<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isLoadingData;
@property (nonatomic) BOOL hasMoreData;
@property (nonatomic) int dataOffset;
@property (nonatomic) CGFloat heightForDataRow;
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;
@property (nonatomic, copy) SPMUTableCellMaker tableCellMaker;
@property (nonatomic, strong) IBOutlet UITableView *theTableView;

-(void)reloadData;
-(NSInteger)dataCount;
-(id)rowDataAtVirtualIndex:(NSInteger)index;
-(NSInteger)realRowIndexForVirtualIndex:(NSInteger)index;

-(void)finishedLoadingData:(NSArray *)data
                  atOffset:(NSInteger)offset
              withMaxCount:(NSInteger)maxCount
                 withToken:(NSString *)token
                   hasMore:(BOOL)hasMore;
-(void)errorLoadingDataAtOffset:(NSInteger)offset
                  expectedCount:(NSInteger)expectedCount
                      withToken:(NSString *)token
                      withError:(NSError *)error;
-(void)loadDataAtOffset:(NSInteger)offset
           withMaxCount:(NSInteger)maxCount
            withHandler:(SPMUCallbackHandler)handler;

-(void)tableView:(UITableView *)tableView didSelectDataRowAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForDataRowAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)tableView:(UITableView *)tableView heightForDataRowAtIndexPath:(NSIndexPath *)indexPath;

@end


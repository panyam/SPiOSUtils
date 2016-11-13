//
//  SPMUBaseTableVC.m
//
//  Created by Sri Panyam on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPMobileUtils.h"

#define CHUNK_LOAD_SIZE     10

@interface SPMUBaseTableVC()

@property (nonatomic, copy) NSString *loadToken;
@property (nonatomic, strong) NSMutableArray *rowData;
@property (nonatomic, strong) NSMutableArray *filteredItemList;
@property (nonatomic) BOOL disableRowSelection;
@end

@implementation SPMUBaseTableVC

@synthesize isLoadingData;
@synthesize rowData;
@synthesize hasMoreData;
@synthesize dataOffset;

@synthesize selectedIndexPath;
@synthesize theTableView;
@synthesize tableCellMaker;
@synthesize disableRowSelection;
@synthesize filteredItemList;
@synthesize loadToken;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.isLoadingData && self.appearCount == 0)
        [self reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /** Needed for iOS 6 and iOS 7 compatibility */
    CGRect viewFrame = self.view.frame;
    CGRect tableFrame = self.theTableView.frame;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)])
    {
        CGFloat topLG = self.topLayoutGuide.length;
        CGFloat tabTopLG = self.tabBarController.topLayoutGuide.length;
//        CGFloat blg = self.bottomLayoutGuide.length;
//        CGFloat bblg = self.tabBarController.bottomLayoutGuide.length;
        // this 49 is the size of the tab bar - problem is
        // the bottomLayoutGuide is normally this but it is getting set to 0
        // so we are stuck with having to set this manually
        CGFloat bottomLG = 49; // self.bottomLayoutGuide.length;
        CGFloat bottomLG2 = 0;
        // this assumes table view constraints are set to top and bottom of the VC!
        if (tableFrame.size.height > viewFrame.size.height)
            bottomLG2 = (tableFrame.size.height - viewFrame.size.height);
        theTableView.contentInset = UIEdgeInsetsMake(self.tabBarController ? tabTopLG : topLG,
                                                     0, bottomLG + bottomLG2, 0);
        
        // for "larger" iphones - with 568 pixels
        if (tableFrame.size.height < viewFrame.size.height)
        {
            tableFrame.size.height = viewFrame.size.height;
            self.theTableView.frame = tableFrame;
        }
    }
    else
    {
        tableFrame.size.height = viewFrame.size.height;
        self.theTableView.frame = tableFrame;
    }
}

-(void)releaseResources
{
    self.selectedIndexPath = nil;
    self.loadToken = nil;
    self.tableCellMaker = nil;
    self.theTableView = nil;
    [super releaseResources];
}

-(NSInteger)dataCount
{
    return rowData.count;
}

-(id)rowDataAtVirtualIndex:(NSInteger)index
{
    return [rowData objectAtIndex:index];
}

-(NSInteger)realRowIndexForVirtualIndex:(NSInteger)index
{
    return index;
}

#pragma mark -
#pragma mark - UITableView methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rowData.count + (hasMoreData ? 1 : 0);
}


-(UITableViewCell *)cellForLoadingMoreData
{
    static NSString *identifier = @"SPMULoadingMoreDataCell";
    SPMULoadingDataCell *cell = [self.theTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = (SPMULoadingDataCell *)loadFromNib(@"SPMULoadingDataCell", cell);
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell setIsLoadingData:self.isLoadingData];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dataCount)
    {
        NSAssert(self.hasMoreData, @"Row cannot be more than dataCount when hasMoreData is false");
        // show the "load more data" row
        return [self cellForLoadingMoreData];
    }
    else if (tableCellMaker)
    {
        return tableCellMaker(tableView, indexPath, nil);
    }
    else
    {
        return [self tableView:tableView cellForDataRowAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dataCount)
    {
        self.selectedIndexPath = nil;
        NSAssert(self.hasMoreData, @"Row cannot be more than dataCount when hasMoreData is false");
        // show the "load more data" row
        SPMULoadingDataCell *cell = (SPMULoadingDataCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setIsLoadingData:YES];
        [self kickOffLoadDataAtOffset:dataOffset + self.dataCount
                         withMaxCount:CHUNK_LOAD_SIZE withHandler:^(id result, NSError *error) {
                         }];
    }
    else
    {
        self.selectedIndexPath = indexPath;
        [self tableView:tableView didSelectDataRowAtIndexPath:indexPath];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dataCount)
    {
        return [self heightForLoadingCell];
    }
    else
    {
        return [self tableView:tableView heightForDataRowAtIndexPath:indexPath];
    }
}

-(CGFloat)heightForLoadingCell
{
    return 45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForDataRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.heightForDataRow;
}


-(void)tableView:(UITableView *)tableView didSelectDataRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Override this method to load data into the table");
}

-(UITableViewCell *)tableView:(UITableView *)tableView
    cellForDataRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Override this method to load data into the table");
    return nil;
}

// The method to overload to do the actual data overload
-(void)loadDataAtOffset:(NSInteger)offset
           withMaxCount:(NSInteger)maxCount
            withHandler:(SPMUCallbackHandler)handler
{
    NSAssert(NO, @"Override this method to load data into the table");
}

-(BOOL)kickOffLoadDataAtOffset:(NSInteger)offset
                  withMaxCount:(NSInteger)maxCount
                   withHandler:(SPMUCallbackHandler)handler
{
    self.loadToken = NSProcessInfo.processInfo.globallyUniqueString;
    NSString *tokenAtStart = [self.loadToken copy];
    [SPMU_ACTIVITY_INDICATOR showWithMessage:@"Loading content..."];
    self.isLoadingData = YES;
    handler = [handler copy];
    [self loadDataAtOffset:offset
              withMaxCount:maxCount
               withHandler:
     ^(id result, NSError *error) {
         if (error)
         {
             [self errorLoadingDataAtOffset:offset expectedCount:maxCount withToken:tokenAtStart withError:error];
             [SPMU_ACTIVITY_INDICATOR hide];
         }
         else
         {
             if ([self.loadToken isEqualToString:tokenAtStart])
             {
                 NSArray *items = (NSArray *)result;
                 self.hasMoreData = items.count > maxCount;
                 if (self.hasMoreData)
                 {
                     for (int i = 0;i < maxCount;i++)
                         [self.rowData addObject:[items objectAtIndex:i]];  // add the fetched data to our contents array
                 }
                 else
                 {
                     [self.rowData addObjectsFromArray:items];  // add the fetched data to our contents array
                 }
                 // reload the table
                 ensure_main_queue(^{
                     [[self theTableView] reloadData];
                 });
                 [self finishedLoadingData:items atOffset:offset
                              withMaxCount:maxCount
                                 withToken:tokenAtStart
                                   hasMore:hasMoreData];
                 if (handler)
                     handler(result, error);
                 self.isLoadingData = NO;
                 [SPMU_ACTIVITY_INDICATOR hide];
             }
         }
     }];
    return YES;
}

-(void)reloadData
{
    self.rowData = [NSMutableArray array];
    self.dataOffset = 0;
    [self kickOffLoadDataAtOffset:self.dataOffset withMaxCount:CHUNK_LOAD_SIZE withHandler:nil];
}

-(void)startedLoadingDataAtOffset:(NSInteger)offset withMaxCount:(NSInteger)maxCount withToken:(NSString *)token
{
//    [self lookBusy:YES];
}

-(void)finishedLoadingData:(NSArray *)data atOffset:(NSInteger)offset withMaxCount:(NSInteger)maxCount withToken:(NSString *)token hasMore:(BOOL)hasMore
{
}

-(void)errorLoadingDataAtOffset:(NSInteger)offset
                  expectedCount:(NSInteger)expectedCount
                      withToken:(NSString *)token
                      withError:(NSError *)error
{
    presentErrorRateLimited(error, 30);
}

@end


#import "SPMobileUtils.h"
#include <math.h>
#include <stdarg.h>

/**
 * Helper to prepare and return a sql string.
 */
sqlite3_stmt *prepare_sql(sqlite3 *database, NSString *sql_str, BOOL log_sql)
{
    sqlite3_stmt *stmt = NULL;
    int result = sqlite3_prepare_v2(database, [sql_str UTF8String], -1, &stmt, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Could not prepare sql [[[ %@ ]]], Error: %s", sql_str, sqlite3_errmsg(database));
        assert(false);
    }
    else
    {
#if TARGET_IPHONE_SIMULATOR
        if (log_sql)
        {
            // NSLog(@"Prepared Sql: %@", sql_str);
        }
#endif
    }
    return stmt;
}

/**
 * Create a table with a given name, columns and primary key and uniqueness constraints.
 */
void createTableWithName(sqlite3 *database, NSString *tableName, NSArray *columns, NSString *constraintType, ...)
{
    NSMutableString *sql_str = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS '"];
    [sql_str appendString:tableName];
    [sql_str appendString:@"' ("];
    int index = 0;
    for (NSString *value in columns)
    {
        if (index > 0 && index % 2 == 0)
            [sql_str appendFormat:@","];
        [sql_str appendString:@" "];
        [sql_str appendString:value];
        index++;
    }
    
    if (constraintType)
    {
        CREATE_VA_LIST(args, constraintType);
        do 
        {
            NSArray *constraintsList = ns_va_arg(args, NSArray *);
            if (constraintsList)
            {
                [sql_str appendFormat:@", %@ (", constraintType];
                [sql_str appendString:[constraintsList componentsJoinedByString:@","]];
                [sql_str appendString:@")"];
            }
            else
            {
                [sql_str appendFormat:@", %@", constraintType];
            }
            constraintType = ns_va_arg(args, NSString *);
        } while (constraintType != nil);
    }
    [sql_str appendString:@")"];
    
    sqlite3_stmt *create_sql = prepare_sql(database, sql_str, YES);
    int result = sqlite3_step(create_sql);
    if (result != SQLITE_DONE)
    {
        NSLog(@"Could not create table (%@): %s", tableName, sqlite3_errmsg(database));
        assert(false);
    }
    CLOSE_SQL(create_sql);
}


/**
 * Binds a text field value to a multi-step sql statement. Use this can handle nil string.
 */
int bindTextValueToSqlStatement(NSString *textValue,
                                        sqlite3_stmt *stmt,
                                        int column)
{
    return sqlite3_bind_text(stmt, column, [NONULL(textValue) cStringUsingEncoding:NSASCIIStringEncoding], -1, SQLITE_TRANSIENT);
}

void upsertIntoTable(sqlite3 *database, NSString *tableName,
                     NSArray *columns, NSArray *values, NSString *where_clause)
{
    // do an update
    NSMutableString *sql_str = [NSMutableString stringWithFormat:@"UPDATE '%@' SET ", tableName];
    for (int i = 0, first = -1, count = columns.count;i < count;i++)
    {
        id value = [values objectAtIndex:i];
        if (value && value != [NSNull null])
        {
            if (first >= 0)
                [sql_str appendString:@", "];
            [sql_str appendFormat:@"%@=%@", [columns objectAtIndex:i], value];
            first = i;
        }
    }
    if (where_clause)
        [sql_str appendFormat:@" WHERE %@", where_clause];
    sqlite3_stmt *update_sql = prepare_sql(database, sql_str, NO);
    int step_result = sqlite3_step(update_sql);
    if (step_result != SQLITE_DONE)
    {
        NSLog(@"Row Update Error: %s", sqlite3_errmsg(database));
        assert(NO && "Could not perform row insertion");
    }
    int numChanges = sqlite3_changes(database);
    CLOSE_SQL(update_sql);
    if (numChanges <= 0)    // no rows updated so insert
    {
        // do an insert
        NSMutableString *columns_str = [NSMutableString string];
        NSMutableString *values_str = [NSMutableString string];
        for (int i = 0, first = -1, count = columns.count;i < count;i++)
        {
            id value = [values objectAtIndex:i];
            if (value && value != [NSNull null])
            {
                if (first >= 0)
                {
                    [columns_str appendString:@", "];
                    [values_str appendString:@", "];
                }
                [columns_str appendString:[columns objectAtIndex:i]];
                [values_str appendFormat:@"%@", value];
                first = i;
            }
        }
        NSMutableString *sql_str = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO '%@' (%@) VALUES (%@)",tableName, columns_str, values_str];
        sqlite3_stmt *insert_sql = prepare_sql(database, sql_str, NO);
        int step_result = sqlite3_step(insert_sql);
        if (step_result != SQLITE_DONE)
        {
            NSLog(@"Row Insertion Error: %s", sqlite3_errmsg(database));
            assert(NO && "Could not perform row insertion");
        }
        CLOSE_SQL(insert_sql);
    }
}


#ifndef __SPMU_SQL_UTILS_H__
#define __SPMU_SQL_UTILS_H__

#import "SPMUFwdDefs.h"
#import <sqlite3.h>

#define CLEAN_SQUOTE(str)   [NONULL(str) stringByReplacingOccurrencesOfString:@"'" withString:@"''"]
#define QUOTE(str)          [NSString stringWithFormat:@"'%@'", NONULL(str)]
#define NIL_OWNER_ID        @"<none>"

#define CLOSE_SQL(stmt)     sqlite3_reset(stmt); sqlite3_finalize(stmt); stmt=NULL

/**
 * Helper to prepare and return a sql string.
 */
extern sqlite3_stmt *prepare_sql(sqlite3 *database, NSString *sql_str, BOOL log_sql);

/**
 * A custom sqlite function that calculates the distance from of a record's given lat/lng 
 * fields to another lat/lng value (either as constants or field values).
 */
extern void dist_squared(sqlite3_context *context, int argc, sqlite3_value **argv);

/**
 * A custom sqlite function that allows ordering based on an if logic expression.
 */
extern void tiered_time(sqlite3_context *context, int argc, sqlite3_value **argv);

/**
 * Create a table with a given name, columns and primary key and uniqueness constraints.
 */
extern void createTableWithName(sqlite3 *database, NSString *tableName, NSArray *columns, NSString *constraintType, ...);

/**
 * Binds a text field value to a multi-step sql statement. Use this can handle nil string.
 */
extern int bindTextValueToSqlStatement(NSString *textValue,
                                        sqlite3_stmt *stmt,
                                        int column);

extern void upsertIntoTable(sqlite3 *database, NSString *tableName, NSArray *columns, NSArray *values, NSString *where_clause);

#endif


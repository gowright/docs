# Database Testing

Gowright provides comprehensive database testing capabilities with support for multiple database systems, transaction management, and data validation. Built with Go's standard `database/sql` package and popular drivers.

## Overview

The database testing module provides:

- Multi-database support (PostgreSQL, MySQL, SQLite, SQL Server, Oracle)
- Transaction management and rollback testing
- Complex query validation and result verification
- Data integrity and constraint testing
- Migration testing and schema validation
- Connection pooling and resource management
- Performance testing and query optimization

## Supported Databases

### PostgreSQL

```go
config := &gowright.DatabaseConfig{
    Connections: map[string]*gowright.DBConnection{
        "postgres": {
            Driver: "postgres",
            DSN:    "postgres://user:password@localhost/testdb?sslmode=disable",
            MaxOpenConns: 10,
            MaxIdleConns: 5,
        },
    },
}
```

### MySQL

```go
config := &gowright.DatabaseConfig{
    Connections: map[string]*gowright.DBConnection{
        "mysql": {
            Driver: "mysql",
            DSN:    "user:password@tcp(localhost:3306)/testdb",
            MaxOpenConns: 10,
            MaxIdleConns: 5,
        },
    },
}
```

### SQLite

```go
config := &gowright.DatabaseConfig{
    Connections: map[string]*gowright.DBConnection{
        "sqlite": {
            Driver: "sqlite3",
            DSN:    "./test.db", // or ":memory:" for in-memory
            MaxOpenConns: 1,     // SQLite doesn't support concurrent writes
            MaxIdleConns: 1,
        },
    },
}
```

## Basic Usage

### Simple Database Test

```go
package main

import (
    "testing"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
    _ "github.com/mattn/go-sqlite3" // Import SQLite driver
)

func TestBasicDatabaseOperation(t *testing.T) {
    // Create database tester
    dbTester := gowright.NewDatabaseTester()
    
    config := &gowright.DatabaseConfig{
        Connections: map[string]*gowright.DBConnection{
            "test": {
                Driver: "sqlite3",
                DSN:    ":memory:",
            },
        },
    }
    
    err := dbTester.Initialize(config)
    assert.NoError(t, err)
    defer dbTester.Cleanup()
    
    // Create test table
    _, err = dbTester.Execute("test", `
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)
    assert.NoError(t, err)
    
    // Insert test data
    _, err = dbTester.Execute("test", 
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "John Doe", "john@example.com")
    assert.NoError(t, err)
    
    // Query and validate
    rows, err := dbTester.Query("test", "SELECT name, email FROM users WHERE id = ?", 1)
    assert.NoError(t, err)
    assert.Len(t, rows, 1)
    assert.Equal(t, "John Doe", rows[0]["name"])
    assert.Equal(t, "john@example.com", rows[0]["email"])
}
```

### Using Database Test Builder

```go
func TestWithDatabaseTestBuilder(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    
    config := &gowright.DatabaseConfig{
        Connections: map[string]*gowright.DBConnection{
            "test": {
                Driver: "sqlite3",
                DSN:    ":memory:",
            },
        },
    }
    
    err := dbTester.Initialize(config)
    assert.NoError(t, err)
    defer dbTester.Cleanup()
    
    // Setup test table
    _, err = dbTester.Execute("test", `
        CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            price DECIMAL(10,2),
            category_id INTEGER,
            active BOOLEAN DEFAULT 1
        )
    `)
    assert.NoError(t, err)
    
    // Create structured database test
    dbTest := &gowright.DatabaseTest{
        Name:       "Product Creation Test",
        Connection: "test",
        Setup: []string{
            "INSERT INTO products (name, price, category_id) VALUES ('Laptop', 999.99, 1)",
            "INSERT INTO products (name, price, category_id) VALUES ('Mouse', 29.99, 1)",
            "INSERT INTO products (name, price, category_id) VALUES ('Keyboard', 79.99, 1)",
        },
        Query: "SELECT COUNT(*) as count FROM products WHERE category_id = ? AND active = ?",
        Args:  []interface{}{1, true},
        Expected: &gowright.DatabaseExpectation{
            RowCount: 3,
            Columns: map[string]interface{}{
                "count": 3,
            },
        },
        Teardown: []string{
            "DELETE FROM products WHERE category_id = 1",
        },
    }
    
    result := dbTester.ExecuteTest(dbTest)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

## Query Operations

### SELECT Queries

```go
func TestSelectQueries(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Simple select
    rows, err := dbTester.Query("test", "SELECT * FROM users")
    assert.NoError(t, err)
    
    // Select with parameters
    rows, err = dbTester.Query("test", 
        "SELECT name, email FROM users WHERE age > ? AND city = ?", 
        25, "New York")
    assert.NoError(t, err)
    
    // Select single row
    row, err := dbTester.QueryRow("test", 
        "SELECT name FROM users WHERE id = ?", 1)
    assert.NoError(t, err)
    assert.Equal(t, "John Doe", row["name"])
    
    // Select with complex conditions
    rows, err = dbTester.Query("test", `
        SELECT u.name, u.email, p.title 
        FROM users u 
        JOIN posts p ON u.id = p.user_id 
        WHERE u.active = ? AND p.published_at > ?`,
        true, "2024-01-01")
    assert.NoError(t, err)
}
```

### INSERT Operations

```go
func TestInsertOperations(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Simple insert
    result, err := dbTester.Execute("test",
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "Jane Smith", "jane@example.com")
    assert.NoError(t, err)
    
    // Get last insert ID
    lastID, err := result.LastInsertId()
    assert.NoError(t, err)
    assert.Greater(t, lastID, int64(0))
    
    // Batch insert
    users := [][]interface{}{
        {"Alice Johnson", "alice@example.com"},
        {"Bob Wilson", "bob@example.com"},
        {"Carol Brown", "carol@example.com"},
    }
    
    for _, user := range users {
        _, err := dbTester.Execute("test",
            "INSERT INTO users (name, email) VALUES (?, ?)",
            user[0], user[1])
        assert.NoError(t, err)
    }
    
    // Verify batch insert
    rows, err := dbTester.Query("test", "SELECT COUNT(*) as count FROM users")
    assert.NoError(t, err)
    assert.Equal(t, 4, rows[0]["count"]) // 1 initial + 3 batch
}
```

### UPDATE Operations

```go
func TestUpdateOperations(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Simple update
    result, err := dbTester.Execute("test",
        "UPDATE users SET email = ? WHERE id = ?",
        "newemail@example.com", 1)
    assert.NoError(t, err)
    
    // Check affected rows
    rowsAffected, err := result.RowsAffected()
    assert.NoError(t, err)
    assert.Equal(t, int64(1), rowsAffected)
    
    // Bulk update
    result, err = dbTester.Execute("test",
        "UPDATE users SET active = ? WHERE created_at < ?",
        false, "2023-01-01")
    assert.NoError(t, err)
    
    // Conditional update
    result, err = dbTester.Execute("test", `
        UPDATE users 
        SET last_login = CURRENT_TIMESTAMP 
        WHERE email = ? AND active = ?`,
        "user@example.com", true)
    assert.NoError(t, err)
}
```

### DELETE Operations

```go
func TestDeleteOperations(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Simple delete
    result, err := dbTester.Execute("test",
        "DELETE FROM users WHERE id = ?", 1)
    assert.NoError(t, err)
    
    rowsAffected, err := result.RowsAffected()
    assert.NoError(t, err)
    assert.Equal(t, int64(1), rowsAffected)
    
    // Conditional delete
    result, err = dbTester.Execute("test",
        "DELETE FROM users WHERE active = ? AND last_login < ?",
        false, "2023-01-01")
    assert.NoError(t, err)
    
    // Cascade delete (if foreign keys are set up)
    result, err = dbTester.Execute("test",
        "DELETE FROM users WHERE id IN (SELECT user_id FROM inactive_users)")
    assert.NoError(t, err)
}
```

## Transaction Management

The Gowright framework provides comprehensive transaction management capabilities including basic transactions, rollbacks, savepoints, isolation testing, deadlock handling, and performance optimization.

### Basic Transactions

```go
func TestTransactions(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Begin transaction
    tx, err := dbTester.BeginTransaction("test")
    assert.NoError(t, err)
    
    // Execute operations within transaction
    _, err = tx.Execute("INSERT INTO users (name, email) VALUES (?, ?)",
        "Transaction User", "tx@example.com")
    assert.NoError(t, err)
    
    _, err = tx.Execute("INSERT INTO profiles (user_id, bio) VALUES (?, ?)",
        1, "Test bio")
    assert.NoError(t, err)
    
    // Commit transaction
    err = tx.Commit()
    assert.NoError(t, err)
    
    // Verify data was committed
    rows, err := dbTester.Query("test", 
        "SELECT COUNT(*) as count FROM users WHERE email = ?", 
        "tx@example.com")
    assert.NoError(t, err)
    assert.Equal(t, 1, rows[0]["count"])
}
```

### Advanced Transaction Testing

```go
func TestAdvancedTransactions(t *testing.T) {
    config := &gowright.DatabaseConfig{
        Connections: map[string]*gowright.DBConnection{
            "primary": {
                Driver:       "sqlite3",
                DSN:          ":memory:",
                MaxOpenConns: 10,
                MaxIdleConns: 5,
            },
        },
    }

    tester := gowright.NewDatabaseTester(config)
    err := tester.Initialize(config)
    assert.NoError(t, err)
    defer tester.Cleanup()

    // Test transaction commit with balance transfer
    commitTest := gowright.NewDatabaseTest("Transaction Commit Test", "primary")
    
    commitTest.AddSetupQuery(`
        CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(100) NOT NULL,
            balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)

    commitTest.AddSetupQuery(`
        INSERT INTO accounts (name, balance) VALUES 
        ('Alice', 1000.00),
        ('Bob', 500.00)
    `)

    // Execute transaction
    commitTest.AddSetupQuery(`
        BEGIN TRANSACTION;
        UPDATE accounts SET balance = balance - 100.00 WHERE name = 'Alice';
        UPDATE accounts SET balance = balance + 100.00 WHERE name = 'Bob';
        COMMIT;
    `)

    commitTest.SetQuery("SELECT name, balance FROM accounts ORDER BY name")
    commitTest.SetExpectedRowCount(2)
    
    commitTest.AddCustomAssertion(func(rows []map[string]interface{}) error {
        expectedBalances := map[string]float64{
            "Alice": 900.00,
            "Bob":   600.00,
        }
        
        for _, row := range rows {
            name := row["name"].(string)
            balance := row["balance"].(float64)
            
            if expectedBalance, exists := expectedBalances[name]; exists {
                if balance != expectedBalance {
                    return fmt.Errorf("expected %s balance to be %.2f, got %.2f", 
                        name, expectedBalance, balance)
                }
            }
        }
        
        return nil
    })

    result := commitTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Transaction Rollback

```go
func TestTransactionRollback(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Get initial count
    initialRows, err := dbTester.Query("test", "SELECT COUNT(*) as count FROM users")
    assert.NoError(t, err)
    initialCount := initialRows[0]["count"].(int)
    
    // Begin transaction
    tx, err := dbTester.BeginTransaction("test")
    assert.NoError(t, err)
    
    // Execute operations
    _, err = tx.Execute("INSERT INTO users (name, email) VALUES (?, ?)",
        "Rollback User", "rollback@example.com")
    assert.NoError(t, err)
    
    // Simulate error condition and rollback
    err = tx.Rollback()
    assert.NoError(t, err)
    
    // Verify data was not committed
    finalRows, err := dbTester.Query("test", "SELECT COUNT(*) as count FROM users")
    assert.NoError(t, err)
    finalCount := finalRows[0]["count"].(int)
    
    assert.Equal(t, initialCount, finalCount)
}
```

### Savepoints (Nested Transactions)

```go
func TestSavepoints(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup (PostgreSQL or SQL Server)
    
    tx, err := dbTester.BeginTransaction("test")
    assert.NoError(t, err)
    defer tx.Rollback()
    
    // Insert first user
    _, err = tx.Execute("INSERT INTO users (name, email) VALUES (?, ?)",
        "User 1", "user1@example.com")
    assert.NoError(t, err)
    
    // Create savepoint
    err = tx.Savepoint("sp1")
    assert.NoError(t, err)
    
    // Insert second user
    _, err = tx.Execute("INSERT INTO users (name, email) VALUES (?, ?)",
        "User 2", "user2@example.com")
    assert.NoError(t, err)
    
    // Rollback to savepoint (removes User 2, keeps User 1)
    err = tx.RollbackToSavepoint("sp1")
    assert.NoError(t, err)
    
    // Commit transaction
    err = tx.Commit()
    assert.NoError(t, err)
    
    // Verify only User 1 exists
    rows, err := dbTester.Query("test", "SELECT name FROM users ORDER BY id")
    assert.NoError(t, err)
    assert.Len(t, rows, 1)
    assert.Equal(t, "User 1", rows[0]["name"])
}
```

### Complex Savepoint Testing

```go
func TestComplexSavepoints(t *testing.T) {
    savepointTest := gowright.NewDatabaseTest("Savepoint Test", "primary")
    
    // Setup accounts table
    savepointTest.AddSetupQuery(`
        CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR(100) NOT NULL,
            balance DECIMAL(10,2) NOT NULL DEFAULT 0.00
        )
    `)

    savepointTest.AddSetupQuery(`
        INSERT INTO accounts (name, balance) VALUES 
        ('Alice', 900.00),
        ('Bob', 600.00)
    `)
    
    // Complex nested transaction with savepoints
    savepointTest.AddSetupQuery(`
        BEGIN TRANSACTION;
        UPDATE accounts SET balance = balance - 50.00 WHERE name = 'Alice';
        SAVEPOINT sp1;
        UPDATE accounts SET balance = balance - 100.00 WHERE name = 'Alice';
        ROLLBACK TO SAVEPOINT sp1;
        UPDATE accounts SET balance = balance + 25.00 WHERE name = 'Bob';
        COMMIT;
    `)

    savepointTest.SetQuery("SELECT name, balance FROM accounts ORDER BY name")
    savepointTest.SetExpectedRowCount(2)
    
    savepointTest.AddCustomAssertion(func(rows []map[string]interface{}) error {
        expectedBalances := map[string]float64{
            "Alice": 850.00, // 900 - 50 (first update committed, second rolled back)
            "Bob":   625.00, // 600 + 25 (update after savepoint committed)
        }
        
        for _, row := range rows {
            name := row["name"].(string)
            balance := row["balance"].(float64)
            
            if expectedBalance, exists := expectedBalances[name]; exists {
                if balance != expectedBalance {
                    return fmt.Errorf("with savepoints, expected %s balance to be %.2f, got %.2f", 
                        name, expectedBalance, balance)
                }
            }
        }
        
        return nil
    })

    result := savepointTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Transaction Isolation Testing

```go
func TestTransactionIsolation(t *testing.T) {
    isolationTest := gowright.NewDatabaseTest("Transaction Isolation Test", "primary")
    
    // Create transaction log table
    isolationTest.AddSetupQuery(`
        CREATE TABLE transaction_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id VARCHAR(50),
            action VARCHAR(100),
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)

    // Simulate concurrent transactions
    isolationTest.AddSetupQuery(`
        INSERT INTO transaction_log (transaction_id, action) VALUES ('tx1', 'BEGIN');
        INSERT INTO transaction_log (transaction_id, action) VALUES ('tx1', 'UPDATE accounts SET balance = balance - 75 WHERE name = ''Alice''');
        INSERT INTO transaction_log (transaction_id, action) VALUES ('tx2', 'BEGIN');
        INSERT INTO transaction_log (transaction_id, action) VALUES ('tx2', 'SELECT balance FROM accounts WHERE name = ''Alice''');
        INSERT INTO transaction_log (transaction_id, action) VALUES ('tx1', 'COMMIT');
        INSERT INTO transaction_log (transaction_id, action) VALUES ('tx2', 'COMMIT');
    `)

    isolationTest.SetQuery("SELECT COUNT(*) as log_count FROM transaction_log")
    isolationTest.SetExpectedRowCount(1)
    isolationTest.SetExpectedColumnValue("log_count", 6)

    result := isolationTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Deadlock Detection and Handling

```go
func TestDeadlockHandling(t *testing.T) {
    deadlockTest := gowright.NewDatabaseTest("Deadlock Handling Test", "primary")
    
    // Create resources table for deadlock simulation
    deadlockTest.AddSetupQuery(`
        CREATE TABLE resources (
            id INTEGER PRIMARY KEY,
            name VARCHAR(50),
            value INTEGER
        )
    `)

    deadlockTest.AddSetupQuery(`
        INSERT INTO resources (id, name, value) VALUES 
        (1, 'Resource A', 100),
        (2, 'Resource B', 200)
    `)

    // Simulate potential deadlock scenario
    deadlockTest.AddSetupQuery(`
        BEGIN TRANSACTION;
        UPDATE resources SET value = value + 10 WHERE id = 1;
        UPDATE resources SET value = value - 5 WHERE id = 2;
        COMMIT;
    `)

    deadlockTest.SetQuery("SELECT id, name, value FROM resources ORDER BY id")
    deadlockTest.SetExpectedRowCount(2)
    
    deadlockTest.AddCustomAssertion(func(rows []map[string]interface{}) error {
        expectedValues := map[int64]int64{
            1: 110, // 100 + 10
            2: 195, // 200 - 5
        }
        
        for _, row := range rows {
            id := row["id"].(int64)
            value := row["value"].(int64)
            
            if expectedValue, exists := expectedValues[id]; exists {
                if value != expectedValue {
                    return fmt.Errorf("expected resource %d value to be %d, got %d", 
                        id, expectedValue, value)
                }
            }
        }
        
        return nil
    })

    result := deadlockTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Long-Running Transaction Testing

```go
func TestLongRunningTransactions(t *testing.T) {
    longTxTest := gowright.NewDatabaseTest("Long Transaction Test", "primary")
    
    // Create batch operations table
    longTxTest.AddSetupQuery(`
        CREATE TABLE batch_operations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            batch_id VARCHAR(50),
            operation VARCHAR(100),
            processed_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)

    // Insert multiple records in a single transaction
    longTxTest.AddSetupQuery("BEGIN TRANSACTION")
    
    for i := 1; i <= 100; i++ {
        longTxTest.AddSetupQuery(fmt.Sprintf(
            "INSERT INTO batch_operations (batch_id, operation) VALUES ('batch_001', 'operation_%d')",
            i,
        ))
    }
    
    longTxTest.AddSetupQuery("COMMIT")

    longTxTest.SetQuery("SELECT COUNT(*) as operation_count FROM batch_operations WHERE batch_id = 'batch_001'")
    longTxTest.SetExpectedRowCount(1)
    longTxTest.SetExpectedColumnValue("operation_count", 100)

    result := longTxTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Multi-Database Transaction Testing

```go
func TestMultiDatabaseTransactions(t *testing.T) {
    multiDbTest := gowright.NewDatabaseTest("Multi-database Transaction Test", "secondary")
    
    // Setup audit table in secondary database
    multiDbTest.AddSetupQuery(`
        CREATE TABLE IF NOT EXISTS audit_trail (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_name VARCHAR(50),
            operation VARCHAR(20),
            record_id INTEGER,
            old_values TEXT,
            new_values TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)

    // Simulate audit logging for account transactions
    multiDbTest.AddSetupQuery(`
        INSERT INTO audit_trail (table_name, operation, record_id, old_values, new_values) VALUES 
        ('accounts', 'UPDATE', 1, '{"balance": 900.00}', '{"balance": 850.00}'),
        ('accounts', 'UPDATE', 2, '{"balance": 600.00}', '{"balance": 625.00}')
    `)

    multiDbTest.SetQuery("SELECT COUNT(*) as audit_count FROM audit_trail WHERE table_name = 'accounts'")
    multiDbTest.SetExpectedRowCount(1)
    multiDbTest.SetExpectedColumnValue("audit_count", 2)

    result := multiDbTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Transaction Performance Testing

```go
func TestTransactionPerformance(t *testing.T) {
    performanceTest := gowright.NewDatabaseTest("Transaction Performance Test", "primary")
    
    // Create performance test table
    performanceTest.AddSetupQuery(`
        CREATE TABLE performance_test (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data VARCHAR(100),
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)

    // Measure transaction performance
    startTime := time.Now()
    
    performanceTest.AddSetupQuery("BEGIN TRANSACTION")
    
    // Insert many records in single transaction
    for i := 1; i <= 1000; i++ {
        performanceTest.AddSetupQuery(fmt.Sprintf(
            "INSERT INTO performance_test (data) VALUES ('performance_data_%d')",
            i,
        ))
    }
    
    performanceTest.AddSetupQuery("COMMIT")
    
    performanceTest.SetQuery("SELECT COUNT(*) as record_count FROM performance_test")
    performanceTest.SetExpectedRowCount(1)
    performanceTest.SetExpectedColumnValue("record_count", 1000)
    
    performanceTest.AddCustomAssertion(func(rows []map[string]interface{}) error {
        duration := time.Since(startTime)
        if duration > 10*time.Second {
            return fmt.Errorf("transaction took too long: %v", duration)
        }
        
        fmt.Printf("   Transaction completed in: %v\n", duration)
        return nil
    })

    result := performanceTest.Execute(tester)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

## Data Validation

### Schema Validation

```go
func TestSchemaValidation(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Test table exists
    exists, err := dbTester.TableExists("test", "users")
    assert.NoError(t, err)
    assert.True(t, exists)
    
    // Test column exists
    exists, err = dbTester.ColumnExists("test", "users", "email")
    assert.NoError(t, err)
    assert.True(t, exists)
    
    // Test index exists
    exists, err = dbTester.IndexExists("test", "idx_users_email")
    assert.NoError(t, err)
    assert.True(t, exists)
    
    // Validate table structure
    columns, err := dbTester.GetTableColumns("test", "users")
    assert.NoError(t, err)
    
    expectedColumns := map[string]string{
        "id":         "INTEGER",
        "name":       "TEXT",
        "email":      "TEXT",
        "created_at": "DATETIME",
    }
    
    for colName, colType := range expectedColumns {
        assert.Contains(t, columns, colName)
        assert.Equal(t, colType, columns[colName])
    }
}
```

### Constraint Testing

```go
func TestConstraints(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Test unique constraint
    _, err := dbTester.Execute("test",
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "User 1", "unique@example.com")
    assert.NoError(t, err)
    
    // This should fail due to unique constraint
    _, err = dbTester.Execute("test",
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "User 2", "unique@example.com")
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "UNIQUE constraint failed")
    
    // Test NOT NULL constraint
    _, err = dbTester.Execute("test",
        "INSERT INTO users (email) VALUES (?)", "nonull@example.com")
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "NOT NULL constraint failed")
    
    // Test foreign key constraint (if enabled)
    _, err = dbTester.Execute("test",
        "INSERT INTO posts (user_id, title) VALUES (?, ?)",
        999, "Post with invalid user")
    assert.Error(t, err)
}
```

### Data Integrity Testing

```go
func TestDataIntegrity(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Test referential integrity
    dbTest := &gowright.DatabaseTest{
        Name:       "Referential Integrity Test",
        Connection: "test",
        Setup: []string{
            "INSERT INTO users (id, name, email) VALUES (1, 'User 1', 'user1@example.com')",
            "INSERT INTO posts (user_id, title, content) VALUES (1, 'Post 1', 'Content 1')",
        },
        Query: `
            SELECT COUNT(*) as orphaned_posts 
            FROM posts p 
            LEFT JOIN users u ON p.user_id = u.id 
            WHERE u.id IS NULL
        `,
        Expected: &gowright.DatabaseExpectation{
            Columns: map[string]interface{}{
                "orphaned_posts": 0,
            },
        },
        Teardown: []string{
            "DELETE FROM posts WHERE user_id = 1",
            "DELETE FROM users WHERE id = 1",
        },
    }
    
    result := dbTester.ExecuteTest(dbTest)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

## Migration Testing

### Schema Migration Testing

```go
func TestSchemaMigration(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Initial schema
    _, err := dbTester.Execute("test", `
        CREATE TABLE users_v1 (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL
        )
    `)
    assert.NoError(t, err)
    
    // Insert test data
    _, err = dbTester.Execute("test",
        "INSERT INTO users_v1 (name, email) VALUES (?, ?)",
        "John Doe", "john@example.com")
    assert.NoError(t, err)
    
    // Migration: Add new column
    migrationTest := &gowright.DatabaseTest{
        Name:       "Add Created At Column Migration",
        Connection: "test",
        Setup: []string{
            "CREATE TABLE users_v1_backup AS SELECT * FROM users_v1",
        },
        Migration: []string{
            "ALTER TABLE users_v1 ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP",
        },
        Validation: &gowright.DatabaseExpectation{
            ColumnExists: []string{"created_at"},
            Query:        "SELECT COUNT(*) as count FROM users_v1",
            Columns: map[string]interface{}{
                "count": 1, // Data should be preserved
            },
        },
        Rollback: []string{
            "DROP TABLE users_v1",
            "ALTER TABLE users_v1_backup RENAME TO users_v1",
        },
    }
    
    result := dbTester.ExecuteMigrationTest(migrationTest)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Data Migration Testing

```go
func TestDataMigration(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Setup old schema and data
    _, err := dbTester.Execute("test", `
        CREATE TABLE old_users (
            id INTEGER PRIMARY KEY,
            full_name TEXT NOT NULL,
            email_address TEXT UNIQUE NOT NULL
        )
    `)
    assert.NoError(t, err)
    
    _, err = dbTester.Execute("test",
        "INSERT INTO old_users (full_name, email_address) VALUES (?, ?)",
        "John Doe", "john@example.com")
    assert.NoError(t, err)
    
    // Create new schema
    _, err = dbTester.Execute("test", `
        CREATE TABLE new_users (
            id INTEGER PRIMARY KEY,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            migrated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)
    assert.NoError(t, err)
    
    // Data migration
    dataMigrationTest := &gowright.DatabaseTest{
        Name:       "User Data Migration",
        Connection: "test",
        Migration: []string{
            `INSERT INTO new_users (id, first_name, last_name, email)
             SELECT 
                 id,
                 SUBSTR(full_name, 1, INSTR(full_name, ' ') - 1) as first_name,
                 SUBSTR(full_name, INSTR(full_name, ' ') + 1) as last_name,
                 email_address
             FROM old_users`,
        },
        Validation: &gowright.DatabaseExpectation{
            Query: "SELECT COUNT(*) as count FROM new_users",
            Columns: map[string]interface{}{
                "count": 1,
            },
        },
        PostValidation: []string{
            "SELECT first_name, last_name, email FROM new_users WHERE id = 1",
        },
        Expected: &gowright.DatabaseExpectation{
            Columns: map[string]interface{}{
                "first_name": "John",
                "last_name":  "Doe",
                "email":      "john@example.com",
            },
        },
    }
    
    result := dbTester.ExecuteMigrationTest(dataMigrationTest)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

## Performance Testing

### Query Performance Testing

```go
func TestQueryPerformance(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Create large dataset for performance testing
    tx, err := dbTester.BeginTransaction("test")
    assert.NoError(t, err)
    
    for i := 0; i < 10000; i++ {
        _, err = tx.Execute(
            "INSERT INTO users (name, email) VALUES (?, ?)",
            fmt.Sprintf("User %d", i),
            fmt.Sprintf("user%d@example.com", i))
        assert.NoError(t, err)
    }
    
    err = tx.Commit()
    assert.NoError(t, err)
    
    // Performance test
    performanceTest := &gowright.DatabaseTest{
        Name:       "Query Performance Test",
        Connection: "test",
        Query:      "SELECT * FROM users WHERE email LIKE ? ORDER BY name LIMIT 100",
        Args:       []interface{}{"%user1%"},
        Performance: &gowright.PerformanceExpectation{
            MaxExecutionTime: 100 * time.Millisecond,
            MaxMemoryUsage:   50 * 1024 * 1024, // 50MB
        },
        Expected: &gowright.DatabaseExpectation{
            MaxRowCount: 100,
        },
    }
    
    result := dbTester.ExecutePerformanceTest(performanceTest)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
    assert.True(t, result.ExecutionTime < 100*time.Millisecond)
}
```

### Connection Pool Testing

```go
func TestConnectionPool(t *testing.T) {
    config := &gowright.DatabaseConfig{
        Connections: map[string]*gowright.DBConnection{
            "pool_test": {
                Driver:       "sqlite3",
                DSN:          ":memory:",
                MaxOpenConns: 5,
                MaxIdleConns: 2,
                MaxLifetime:  "1h",
            },
        },
    }
    
    dbTester := gowright.NewDatabaseTester()
    err := dbTester.Initialize(config)
    assert.NoError(t, err)
    defer dbTester.Cleanup()
    
    // Test concurrent connections
    var wg sync.WaitGroup
    errors := make(chan error, 10)
    
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            
            _, err := dbTester.Query("pool_test", 
                "SELECT ? as connection_id", id)
            if err != nil {
                errors <- err
            }
        }(i)
    }
    
    wg.Wait()
    close(errors)
    
    // Check for errors
    for err := range errors {
        t.Errorf("Connection pool error: %v", err)
    }
    
    // Verify pool stats
    stats := dbTester.GetConnectionStats("pool_test")
    assert.LessOrEqual(t, stats.OpenConnections, 5)
    assert.LessOrEqual(t, stats.IdleConnections, 2)
}
```

## Advanced Features

### Custom Matchers

```go
func TestCustomMatchers(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Custom matcher for email validation
    emailMatcher := func(value interface{}) bool {
        email, ok := value.(string)
        if !ok {
            return false
        }
        return strings.Contains(email, "@") && strings.Contains(email, ".")
    }
    
    dbTest := &gowright.DatabaseTest{
        Name:       "Email Validation Test",
        Connection: "test",
        Query:      "SELECT email FROM users WHERE id = ?",
        Args:       []interface{}{1},
        Expected: &gowright.DatabaseExpectation{
            CustomMatchers: map[string]func(interface{}) bool{
                "email": emailMatcher,
            },
        },
    }
    
    result := dbTester.ExecuteTest(dbTest)
    assert.Equal(t, gowright.TestStatusPassed, result.Status)
}
```

### Database Seeding

```go
func TestDatabaseSeeding(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization and setup
    
    // Load seed data from file
    seedData, err := dbTester.LoadSeedData("./testdata/users.json")
    assert.NoError(t, err)
    
    // Apply seed data
    err = dbTester.SeedDatabase("test", seedData)
    assert.NoError(t, err)
    
    // Verify seeded data
    rows, err := dbTester.Query("test", "SELECT COUNT(*) as count FROM users")
    assert.NoError(t, err)
    assert.Greater(t, rows[0]["count"].(int), 0)
}
```

## Configuration Examples

### Complete Database Configuration

```json
{
  "database_config": {
    "connections": {
      "primary": {
        "driver": "postgres",
        "dsn": "postgres://user:pass@localhost/testdb?sslmode=disable",
        "max_open_conns": 25,
        "max_idle_conns": 10,
        "max_lifetime": "1h"
      },
      "secondary": {
        "driver": "mysql",
        "dsn": "user:pass@tcp(localhost:3306)/testdb",
        "max_open_conns": 15,
        "max_idle_conns": 5,
        "max_lifetime": "30m"
      },
      "cache": {
        "driver": "sqlite3",
        "dsn": ":memory:",
        "max_open_conns": 1,
        "max_idle_conns": 1
      }
    },
    "migration_config": {
      "migrations_table": "schema_migrations",
      "migrations_dir": "./migrations"
    },
    "seed_config": {
      "seed_dir": "./testdata/seeds"
    }
  }
}
```

## Best Practices

### 1. Use Transactions for Test Isolation

```go
func TestWithTransactionIsolation(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization
    
    tx, err := dbTester.BeginTransaction("test")
    assert.NoError(t, err)
    defer tx.Rollback() // Always rollback test data
    
    // Your test operations here
    // Data will be automatically cleaned up
}
```

### 2. Use Descriptive Test Names

```go
// Good
func TestUserCannotCreateAccountWithDuplicateEmail(t *testing.T) {}
func TestOrderTotalCalculationWithDiscounts(t *testing.T) {}

// Avoid
func TestInsert(t *testing.T) {}
func TestQuery(t *testing.T) {}
```

### 3. Test Both Success and Failure Cases

```go
func TestConstraintValidation(t *testing.T) {
    // Test success case
    _, err := dbTester.Execute("test",
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "Valid User", "valid@example.com")
    assert.NoError(t, err)
    
    // Test failure case
    _, err = dbTester.Execute("test",
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "Invalid User", "valid@example.com") // Duplicate email
    assert.Error(t, err)
}
```

### 4. Use Parameterized Queries

```go
// Good - prevents SQL injection
rows, err := dbTester.Query("test", 
    "SELECT * FROM users WHERE name = ? AND age > ?", 
    userName, minAge)

// Avoid - vulnerable to SQL injection
rows, err := dbTester.Query("test", 
    fmt.Sprintf("SELECT * FROM users WHERE name = '%s'", userName))
```

### 5. Clean Up Test Data

```go
func TestWithCleanup(t *testing.T) {
    dbTester := gowright.NewDatabaseTester()
    // ... initialization
    
    // Insert test data
    result, err := dbTester.Execute("test",
        "INSERT INTO users (name, email) VALUES (?, ?)",
        "Test User", "test@example.com")
    assert.NoError(t, err)
    
    userID, _ := result.LastInsertId()
    
    // Cleanup after test
    defer func() {
        dbTester.Execute("test", "DELETE FROM users WHERE id = ?", userID)
    }()
    
    // Your test logic here
}
```

## Troubleshooting

### Common Issues

**Driver not found:**
```go
// Import the required database driver
import _ "github.com/lib/pq"           // PostgreSQL
import _ "github.com/go-sql-driver/mysql" // MySQL
import _ "github.com/mattn/go-sqlite3"    // SQLite
```

**Connection timeout:**
```go
// Increase connection timeout
config := &gowright.DatabaseConfig{
    Connections: map[string]*gowright.DBConnection{
        "test": {
            Driver:      "postgres",
            DSN:         "postgres://user:pass@localhost/db?connect_timeout=30",
            MaxOpenConns: 10,
        },
    },
}
```

**Transaction deadlock:**
```go
// Use shorter transactions and proper ordering
tx, err := dbTester.BeginTransaction("test")
defer func() {
    if err != nil {
        tx.Rollback()
    } else {
        tx.Commit()
    }
}()
```

## Next Steps

- [Integration Testing](integration-testing.md) - Combine database with other modules
- [Examples](../examples/database-testing.md) - More database testing examples
- [Best Practices](../reference/best-practices.md) - Database testing best practices
- [Performance Testing](../advanced/parallel-execution.md) - Optimize database test performance
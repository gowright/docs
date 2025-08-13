# Database Testing Examples (3/7 - 43% Complete)

This section contains comprehensive database testing examples for the Gowright testing framework, including basic operations, advanced transaction management, and schema migration testing.

## Basic Database Operations (`database-testing/database_basic.go`) ✅

The basic database testing example demonstrates fundamental database operations including table creation, data insertion, validation, updates, deletes, joins, and aggregate functions.

### Key Features Demonstrated

- **Schema Creation**: Table creation and validation
- **CRUD Operations**: Create, Read, Update, Delete operations
- **Data Validation**: Custom assertions and constraint testing
- **JOIN Operations**: Complex queries with table joins
- **Aggregate Functions**: COUNT, AVG, MIN, MAX operations
- **Multi-database Operations**: Working with multiple database connections

### Example Usage

```go
// Create database configuration
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

// Initialize database tester
tester := gowright.NewDatabaseTester(config)
err := tester.Initialize(config)
defer tester.Cleanup()

// Create and execute database test
schemaTest := gowright.NewDatabaseTest("Schema Creation Test", "primary")
schemaTest.AddSetupQuery(`
    CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) NOT NULL,
        age INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        active BOOLEAN DEFAULT 1
    )
`)

schemaTest.SetQuery("SELECT name FROM sqlite_master WHERE type='table' AND name = 'users'")
schemaTest.SetExpectedRowCount(1)

result := schemaTest.Execute(tester)
```

## Transaction Management (`database-testing/database_transactions.go`) ✅ **NEW**

The transaction management example demonstrates comprehensive transaction testing capabilities including commits, rollbacks, savepoints, isolation testing, deadlock handling, and performance optimization.

### Key Features Demonstrated

- **Basic Transactions**: Commit and rollback operations
- **Nested Transactions**: Savepoint management and partial rollbacks
- **Transaction Isolation**: Testing concurrent transaction behavior
- **Deadlock Handling**: Simulating and handling deadlock scenarios
- **Long-Running Transactions**: Performance testing with large datasets
- **Multi-Database Transactions**: Cross-database transaction coordination
- **Performance Testing**: Transaction throughput and timing validation

### Transaction Commit Example

```go
// Test basic transaction commit
commitTest := gowright.NewDatabaseTest("Transaction Commit Test", "primary")

// Setup accounts table
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

// Custom validation
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
```

### Transaction Rollback Example

```go
// Test transaction rollback
rollbackTest := gowright.NewDatabaseTest("Transaction Rollback Test", "primary")

// Attempt transaction that will be rolled back
rollbackTest.AddSetupQuery(`
    BEGIN TRANSACTION;
    UPDATE accounts SET balance = balance - 200.00 WHERE name = 'Alice';
    UPDATE accounts SET balance = balance + 200.00 WHERE name = 'Bob';
    ROLLBACK;
`)

rollbackTest.SetQuery("SELECT name, balance FROM accounts WHERE name IN ('Alice', 'Bob') ORDER BY name")
rollbackTest.SetExpectedRowCount(2)

rollbackTest.AddCustomAssertion(func(rows []map[string]interface{}) error {
    // Balances should be unchanged after rollback
    expectedBalances := map[string]float64{
        "Alice": 900.00, // Should remain at previous committed value
        "Bob":   600.00, // Should remain at previous committed value
    }
    
    for _, row := range rows {
        name := row["name"].(string)
        balance := row["balance"].(float64)
        
        if expectedBalance, exists := expectedBalances[name]; exists {
            if balance != expectedBalance {
                return fmt.Errorf("after rollback, expected %s balance to be %.2f, got %.2f", 
                    name, expectedBalance, balance)
            }
        }
    }
    
    return nil
})

result := rollbackTest.Execute(tester)
```

### Savepoint (Nested Transactions) Example

```go
// Test nested transactions with savepoints
savepointTest := gowright.NewDatabaseTest("Savepoint Test", "primary")

savepointTest.AddSetupQuery(`
    BEGIN TRANSACTION;
    UPDATE accounts SET balance = balance - 50.00 WHERE name = 'Alice';
    SAVEPOINT sp1;
    UPDATE accounts SET balance = balance - 100.00 WHERE name = 'Alice';
    ROLLBACK TO SAVEPOINT sp1;
    UPDATE accounts SET balance = balance + 25.00 WHERE name = 'Bob';
    COMMIT;
`)

savepointTest.SetQuery("SELECT name, balance FROM accounts WHERE name IN ('Alice', 'Bob') ORDER BY name")
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
```

## Schema Migration Testing (`database-testing/database_migrations.go`) ✅ **NEW**

The schema migration testing example demonstrates comprehensive database migration testing capabilities including forward migrations, rollbacks, data preservation, versioning, and performance testing.

### Key Features Demonstrated

- **Migration System Setup**: Migration tracking table creation and validation
- **Forward Migrations**: Applying migrations in sequence with validation
- **Rollback Migrations**: Rolling back migrations and testing recovery
- **Migration Versioning**: Version management and ordering validation
- **Data Preservation**: Ensuring data integrity during schema changes
- **Schema Validation**: Post-migration schema verification
- **Migration Conflicts**: Handling duplicate and conflicting migrations
- **Performance Testing**: Migration performance impact analysis

### Migration System Setup Example

```go
// Create migration tracking table
migrationTableSQL := `
    CREATE TABLE IF NOT EXISTS schema_migrations (
        version VARCHAR(255) PRIMARY KEY,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        description TEXT,
        checksum VARCHAR(255)
    )
`

err := s.dbTester.Execute(migrationTableSQL)
if err != nil {
    testCase.Fail("Failed to create migration tracking table", err.Error())
    return
}

// Verify table structure
exists, err := s.dbTester.TableExists("schema_migrations")
if err != nil {
    testCase.Fail("Failed to check migration table existence", err.Error())
    return
}

// Check table columns
columns, err := s.dbTester.GetTableColumns("schema_migrations")
expectedColumns := []string{"version", "applied_at", "description", "checksum"}
for _, expectedCol := range expectedColumns {
    found := false
    for _, col := range columns {
        if col.Name == expectedCol {
            found = true
            break
        }
    }
    if !found {
        testCase.Fail(fmt.Sprintf("Missing column: %s", expectedCol), "")
        return
    }
}
```

### Forward Migration Example

```go
// Define test migrations
migrations := []Migration{
    {
        Version:     "001",
        Description: "Create users table",
        UpSQL: `
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username VARCHAR(50) UNIQUE NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `,
        DownSQL: "DROP TABLE users",
    },
    {
        Version:     "002",
        Description: "Add user profiles table",
        UpSQL: `
            CREATE TABLE user_profiles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                first_name VARCHAR(50),
                last_name VARCHAR(50),
                bio TEXT,
                FOREIGN KEY (user_id) REFERENCES users(id)
            )
        `,
        DownSQL: "DROP TABLE user_profiles",
    },
}

// Apply migrations one by one
for _, migration := range migrations {
    // Check if migration already applied
    applied, err := s.isMigrationApplied(migration.Version)
    if err != nil {
        testCase.Fail(fmt.Sprintf("Failed to check migration %s status", migration.Version), err.Error())
        continue
    }

    if applied {
        testCase.AddStep(fmt.Sprintf("Migration %s already applied", migration.Version), "info")
        continue
    }

    // Apply migration
    err = s.applyMigration(migration)
    if err != nil {
        testCase.Fail(fmt.Sprintf("Failed to apply migration %s", migration.Version), err.Error())
        continue
    }

    testCase.AddStep(fmt.Sprintf("Migration %s applied successfully", migration.Version), "pass")
}
```

### Data Preservation Testing Example

```go
// Insert test data before migration
testData := []map[string]interface{}{
    {"username": "testuser1", "email": "test1@example.com"},
    {"username": "testuser2", "email": "test2@example.com"},
    {"username": "testuser3", "email": "test3@example.com"},
}

// Insert test data
for _, data := range testData {
    err = s.dbTester.Insert("users", data)
    if err != nil {
        testCase.Fail(fmt.Sprintf("Failed to insert test data: %v", data), err.Error())
        continue
    }
}

// Count records before migration
countBefore, err := s.dbTester.Count("users", nil)
if err != nil {
    testCase.Fail("Failed to count records before migration", err.Error())
    return
}

// Perform a schema migration that should preserve data
migrationSQL := `ALTER TABLE users ADD COLUMN phone VARCHAR(20);`
err = s.dbTester.Execute(migrationSQL)
if err != nil {
    testCase.Fail("Failed to execute data-preserving migration", err.Error())
    return
}

// Count records after migration
countAfter, err := s.dbTester.Count("users", nil)
if err != nil {
    testCase.Fail("Failed to count records after migration", err.Error())
    return
}

// Verify data preservation
if countBefore != countAfter {
    testCase.Fail("Data loss detected during migration", fmt.Sprintf("Before: %d, After: %d", countBefore, countAfter))
    return
}

// Verify data integrity
users, err := s.dbTester.Select("users", []string{"username", "email"}, nil)
if err != nil {
    testCase.Fail("Failed to verify data integrity", err.Error())
    return
}

// Verify specific data content
for i, user := range users {
    expectedUsername := testData[i]["username"]
    expectedEmail := testData[i]["email"]
    
    if user["username"] != expectedUsername || user["email"] != expectedEmail {
        testCase.Fail("Data content mismatch", fmt.Sprintf("Record %d: expected %v, got %v", i, testData[i], user))
        continue
    }
}
```

### Migration Rollback Example

```go
// Get current migration state
appliedMigrations, err := s.getAppliedMigrations()
if err != nil {
    testCase.Fail("Failed to get applied migrations", err.Error())
    return
}

if len(appliedMigrations) == 0 {
    testCase.AddStep("No migrations to rollback", "info")
    return
}

// Rollback the last migration
lastMigration := appliedMigrations[len(appliedMigrations)-1]

// Execute rollback SQL
rollbackSQL := `
    DROP INDEX IF EXISTS idx_users_username;
    DROP INDEX IF EXISTS idx_users_email;
    DROP INDEX IF EXISTS idx_user_profiles_user_id;
`

err = s.dbTester.Execute(rollbackSQL)
if err != nil {
    testCase.Fail("Failed to execute rollback SQL", err.Error())
    return
}

// Remove migration from tracking table
err = s.removeMigrationRecord(lastMigration)
if err != nil {
    testCase.Fail("Failed to remove migration record", err.Error())
    return
}

// Verify rollback
applied, err := s.isMigrationApplied(lastMigration)
if err != nil {
    testCase.Fail("Failed to verify rollback", err.Error())
    return
}

if applied {
    testCase.Fail("Migration still appears as applied after rollback", "")
    return
}
```

## Running the Examples

### Basic Database Testing

```bash
# Run basic database operations example
go run examples/database-testing/database_basic.go

# Expected output:
# === Gowright Database Testing - Basic Examples ===
# ✅ PASSED - Schema Creation (Duration: 2ms)
# ✅ PASSED - Data Insertion (Duration: 1ms)
# ✅ PASSED - Data Validation (Duration: 1ms)
# ✅ PASSED - UPDATE Operations (Duration: 1ms)
# ✅ PASSED - DELETE Operations (Duration: 1ms)
# ✅ PASSED - JOIN Operations (Duration: 2ms)
# ✅ PASSED - Aggregate Functions (Duration: 1ms)
# ✅ PASSED - Multi-database Operations (Duration: 3ms)
```

### Transaction Management Testing

```bash
# Run transaction management example
go run examples/database-testing/database_transactions.go

# Expected output:
# === Gowright Database Testing - Transaction Management ===
# ✅ PASSED - Transaction Commit (Duration: 2ms)
# ✅ PASSED - Transaction Rollback (Duration: 1ms)
# ✅ PASSED - Nested Transactions (Savepoints) (Duration: 2ms)
# ✅ PASSED - Transaction Isolation (Duration: 1ms)
# ✅ PASSED - Deadlock Handling (Duration: 1ms)
# ✅ PASSED - Long-running Transaction (Duration: 15ms)
# ✅ PASSED - Multi-database Transaction (Duration: 3ms)
# ✅ PASSED - Transaction Performance (Duration: 45ms)
```

### Schema Migration Testing

```bash
# Run schema migration example
go run examples/database-testing/database_migrations.go

# Expected output:
# === Gowright Database Testing - Schema Migrations ===
# ✅ PASSED - Migration System Setup (Duration: 3ms)
# ✅ PASSED - Forward Migrations (Duration: 8ms)
# ✅ PASSED - Rollback Migrations (Duration: 5ms)
# ✅ PASSED - Migration Versioning (Duration: 2ms)
# ✅ PASSED - Data Preservation (Duration: 12ms)
# ✅ PASSED - Schema Validation (Duration: 4ms)
# ✅ PASSED - Migration Conflicts (Duration: 3ms)
# ✅ PASSED - Migration Performance (Duration: 25ms)
```

## Test Reports

All examples generate comprehensive HTML and JSON reports in their respective output directories:

- **Basic Testing Reports**: `./reports/database-basic/`
- **Transaction Testing Reports**: `./reports/database-transactions/`
- **Migration Testing Reports**: `./reports/database-migration-tests/`

The reports include:
- Test execution summary
- Individual test case results
- Performance metrics
- Error details and logs
- Visual charts and graphs

## Configuration Examples

### Multi-Database Configuration

```json
{
  "database_config": {
    "connections": {
      "primary": {
        "driver": "sqlite3",
        "dsn": ":memory:",
        "max_open_conns": 10,
        "max_idle_conns": 5
      },
      "secondary": {
        "driver": "sqlite3",
        "dsn": "./test_secondary.db",
        "max_open_conns": 5,
        "max_idle_conns": 2
      },
      "audit": {
        "driver": "postgres",
        "dsn": "postgres://user:pass@localhost/audit_db?sslmode=disable",
        "max_open_conns": 15,
        "max_idle_conns": 5,
        "max_lifetime": "1h"
      }
    }
  }
}
```

## Best Practices Demonstrated

1. **Transaction Isolation**: Always test both success and failure scenarios
2. **Resource Management**: Proper cleanup and connection management
3. **Performance Testing**: Include timing and resource usage validation
4. **Multi-Database Coordination**: Test cross-database transaction scenarios
5. **Error Handling**: Comprehensive error testing and validation
6. **Custom Assertions**: Use custom validation logic for complex business rules
7. **Reporting**: Generate detailed reports for analysis and debugging

For complete source code and additional examples, see the `examples/database-testing/` directory in the repository.
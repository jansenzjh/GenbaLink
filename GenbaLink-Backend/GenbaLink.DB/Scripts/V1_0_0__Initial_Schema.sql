-- Create ProductSkus table
CREATE TABLE IF NOT EXISTS ProductSkus (
    Id VARCHAR(255) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Category VARCHAR(255) NOT NULL DEFAULT '',
    Color VARCHAR(255) NOT NULL DEFAULT '',
    Size VARCHAR(255) NOT NULL DEFAULT '',
    Price DECIMAL(18,2) NOT NULL DEFAULT 0,
    StockLevel INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Id)
) ENGINE=InnoDB;

-- Create DemandSignals table
CREATE TABLE IF NOT EXISTS DemandSignals (
    Id VARCHAR(255) NOT NULL,
    StoreId VARCHAR(255) NOT NULL DEFAULT '',
    BatchId VARCHAR(255) NOT NULL,
    RawInput TEXT NOT NULL,
    ExtractedCategory VARCHAR(255) NOT NULL DEFAULT '',
    ExtractedColor VARCHAR(255) NOT NULL DEFAULT '',
    ExtractedSize VARCHAR(255) NOT NULL DEFAULT '',
    CapturedAtUtc DATETIME(6) NOT NULL,
    ProcessedAtUtc DATETIME(6) NOT NULL,
    PRIMARY KEY (Id)
) ENGINE=InnoDB;

-- Indexes for DemandSignals (MariaDB 10.11 does not support IF NOT EXISTS for CREATE INDEX)
CREATE INDEX IX_DemandSignals_CapturedAtUtc ON DemandSignals (CapturedAtUtc);
CREATE INDEX IX_DemandSignals_BatchId ON DemandSignals (BatchId);

-- Create ProductSkus table
CREATE TABLE IF NOT EXISTS ProductSkus (
    Id TEXT PRIMARY KEY,
    Name TEXT NOT NULL,
    Category TEXT NOT NULL DEFAULT '',
    Color TEXT NOT NULL DEFAULT '',
    Size TEXT NOT NULL DEFAULT '',
    Price REAL NOT NULL DEFAULT 0,
    StockLevel INTEGER NOT NULL DEFAULT 0
);

-- Create DemandSignals table
CREATE TABLE IF NOT EXISTS DemandSignals (
    Id TEXT PRIMARY KEY,
    StoreId TEXT NOT NULL DEFAULT '',
    BatchId TEXT NOT NULL,
    RawInput TEXT NOT NULL DEFAULT '',
    ExtractedCategory TEXT NOT NULL DEFAULT '',
    ExtractedColor TEXT NOT NULL DEFAULT '',
    ExtractedSize TEXT NOT NULL DEFAULT '',
    CapturedAtUtc TEXT NOT NULL,
    ProcessedAtUtc TEXT NOT NULL
);

-- Indexes for DemandSignals
CREATE INDEX IF NOT EXISTS IX_DemandSignals_CapturedAtUtc ON DemandSignals (CapturedAtUtc);
CREATE INDEX IF NOT EXISTS IX_DemandSignals_BatchId ON DemandSignals (BatchId);

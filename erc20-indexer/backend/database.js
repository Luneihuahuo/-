const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class Database {
  constructor() {
    this.db = new sqlite3.Database(path.join(__dirname, 'transfers.db'));
    this.init();
  }

  init() {
    const createTableQuery = `
      CREATE TABLE IF NOT EXISTS transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_hash TEXT UNIQUE NOT NULL,
        block_number INTEGER NOT NULL,
        from_address TEXT NOT NULL,
        to_address TEXT NOT NULL,
        value TEXT NOT NULL,
        token_address TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `;

    this.db.run(createTableQuery, (err) => {
      if (err) {
        console.error('创建表失败:', err);
      } else {
        console.log('数据库表初始化成功');
      }
    });
  }

  insertTransfer(transfer) {
    return new Promise((resolve, reject) => {
      const query = `
        INSERT OR IGNORE INTO transfers 
        (transaction_hash, block_number, from_address, to_address, value, token_address, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `;
      
      this.db.run(query, [
        transfer.transactionHash,
        transfer.blockNumber,
        transfer.from,
        transfer.to,
        transfer.value,
        transfer.tokenAddress,
        transfer.timestamp
      ], function(err) {
        if (err) {
          reject(err);
        } else {
          resolve(this.lastID);
        }
      });
    });
  }

  getTransfersByAddress(address) {
    return new Promise((resolve, reject) => {
      const query = `
        SELECT * FROM transfers 
        WHERE from_address = ? OR to_address = ?
        ORDER BY timestamp DESC
      `;
      
      this.db.all(query, [address, address], (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
  }

  getAllTransfers() {
    return new Promise((resolve, reject) => {
      const query = 'SELECT * FROM transfers ORDER BY timestamp DESC';
      
      this.db.all(query, [], (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
  }

  close() {
    this.db.close();
  }
}

module.exports = Database;
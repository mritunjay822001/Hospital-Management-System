const oracledb = require('oracledb');
const dotenv = require('dotenv');
dotenv.config();

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  connectString: process.env.DB_CONNECTSTRING,
  poolMin: 1,
  poolMax: 10,
  poolIncrement: 1
};

async function initPool() {
  try {
    await oracledb.createPool(dbConfig);
    console.log('Oracle DB pool created');
  } catch (err) {
    console.error('Error creating Oracle DB pool', err);
    throw err;
  }
}

async function closePool() {
  try {
    const pool = oracledb.getPool();
    if (pool) await pool.close(10);
  } catch (err) {
    console.error('Error closing pool', err);
  }
}

async function simpleExecute(sql, binds = {}, opts = {}) {
  opts.outFormat = oracledb.OUT_FORMAT_OBJECT;
  const pool = oracledb.getPool();
  let conn;
  try {
    conn = await pool.getConnection();
    const result = await conn.execute(sql, binds, opts);
    if (opts.autoCommit) await conn.commit();
    return result;
  } finally {
    if (conn) try { await conn.close(); } catch (e) { console.error(e); }
  }
}

module.exports = { initPool, closePool, simpleExecute };

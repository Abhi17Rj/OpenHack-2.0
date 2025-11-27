const fs = require("fs");
const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,   // from .env
  ssl: {
    ca: fs.readFileSync("./certs/root.crt").toString(),
  },
});


const { Client } = require("pg");

const client = new Client(process.env.DATABASE_URL);

(async () => {
  await client.connect();
  try {
    const results = await client.query("SELECT NOW()");
    console.log(results);
  } catch (err) {
    console.error("error executing query:", err);
  } finally {
    client.end();
  }
})();


module.exports = pool;

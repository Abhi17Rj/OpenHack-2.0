require("dotenv").config();
const express = require("express");
const pool = require("./db");
const multer = require("multer");
const axios = require("axios");
const fs = require("fs");
const FormData = require("form-data");

const app = express();
app.use(express.json());

console.log("Loaded DB URL:", process.env.DATABASE_URL);

// Setup multer for file uploads
const upload = multer({ dest: "uploads/" });

// ----------------- Existing APIs -----------------

app.get("/", (req, res) => {
  res.send("Node + CockroachDB is running!");
});

// Fetch all cards
app.get("/allcards", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM public.card");
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.get("/recent", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM public.card ORDER BY created_date desc LIMIT 1");
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Create a new user
app.post("/users", async (req, res) => {
  try {
    const { full_name, email } = req.body;
    const q = `
      INSERT INTO users (full_name, email) 
      VALUES ($1, $2)
      RETURNING *;
    `;
    const result = await pool.query(q, [full_name, email]);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Insert card manually
app.post("/addcard", async (req, res) => {
  try {
    const { f_name, address, company, phone_no, email } = req.body;
    const query = `
      INSERT INTO public.card (f_name, address, company, phone_no, email)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const result = await pool.query(query, [
      f_name,
      address,
      company,
      phone_no,
      email
    ]);
    res.json(result.rows[0]);  
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Delete a card by ID
app.delete("/deletecard/:id", async (req, res) => {
  try {
    const id = String(req.params.id);
    const query = `
      DELETE FROM public.card
      WHERE c_id = $1
      RETURNING *;
    `;
    const result = await pool.query(query, [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Card not found" });
    }
    res.json({
      message: "Card deleted successfully",
      deleted: result.rows[0]
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// ----------------- New API: Upload & Process Image -----------------

const LLM_API_URL = "http://127.0.0.1:8000/extract?mode=auto"; // FastAPI endpoint

app.post("/upload-card", upload.single("file"), async (req, res) => {
  try {
    console.log(req);
    if (!req.file) {
      return res.status(400).json({ error: "No image uploaded." });
    }

    // Send image to FastAPI LLM service
    const formData = new FormData();
    const fileStream = fs.createReadStream(req.file.path);
    formData.append("file", fileStream, req.file.originalname);
    console.log(formData);
    const llmRes = await axios.post(`${LLM_API_URL}`, formData, {
      headers: formData.getHeaders(),
      //file: FormData.file,
      timeout: 600000,
    });

    const cardData = llmRes.data;

    // Insert extracted data into DB
    const query = `
      INSERT INTO public.card (f_name, address, company, phone_no, email)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;

    const result = await pool.query(query, [
      cardData.name,
      cardData.city,
      cardData.company_name,
      cardData.m_no,
      cardData.mail,
    ]);

    // Cleanup uploaded file
    fs.unlinkSync(req.file.path);

    res.json({
      message: "Card uploaded and processed successfully",
      card: result.rows[0],
    });
  } catch (err) {
    console.error(err);
    if (req.file) fs.unlinkSync(req.file.path);
    res.status(500).json({ error: err.message });
  }
});

// ----------------- Start Server -----------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

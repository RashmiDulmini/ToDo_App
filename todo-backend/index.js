const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'todo_app',
  password: '1234',
  port: 5432,
});

// --- Routes ---

// Get all tasks
app.get("/api/tasks", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM tasks ORDER BY id ASC");
    res.status(200).json(result.rows);
  } catch (err) {
    console.error("GET error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// Add a task
app.post("/api/tasks", async (req, res) => {
  const { title, priority } = req.body;
  try {
    const result = await pool.query(
      "INSERT INTO tasks (title, priority, completed) VALUES ($1, $2, false) RETURNING *",
      [title, priority]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("POST error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// Delete task
app.delete("/api/tasks/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query("DELETE FROM tasks WHERE id = $1", [id]);
    res.status(204).send();
  } catch (err) {
    console.error("DELETE error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// Update task
app.put("/api/tasks/:id", async (req, res) => {
  const { id } = req.params;
  const { title, priority, completed } = req.body;
  try {
    await pool.query(
      "UPDATE tasks SET title = $1, priority = $2, completed = $3 WHERE id = $4",
      [title, priority, completed, id]
    );
    res.status(200).json({ message: "Task updated" });
  } catch (err) {
    console.error("PUT error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// ✅ Start the server (outside all routes)
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
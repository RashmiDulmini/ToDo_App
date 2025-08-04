const pool = require('../db/pool');

// Get all tasks
exports.getAllTasks = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM tasks ORDER BY id ASC");
    res.status(200).json(result.rows);
  } catch (err) {
    console.error("GET error:", err.message);
    res.status(500).json({ error: err.message });
  }
};

// Add a new task
exports.addTask = async (req, res) => {
  const { title, priority, completed = false, notes, date, time, alarm = false, assignedUser = null } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO tasks (title, priority, completed, notes, date, time, alarm, assigned_user)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [title, priority, completed, notes, date, time, alarm, assignedUser]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("POST error:", err.message);
    res.status(500).json({ error: err.message });
  }
};

// Delete task
exports.deleteTask = async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query("DELETE FROM tasks WHERE id = $1", [id]);
    res.status(204).send();
  } catch (err) {
    console.error("DELETE error:", err.message);
    res.status(500).json({ error: err.message });
  }
};

// Update task
exports.updateTask = async (req, res) => {
  const { id } = req.params;
  const { title, priority, completed, notes, date, time, alarm, assignedUser } = req.body;

  try {
    await pool.query(
      `UPDATE tasks
       SET title = $1,
           priority = $2,
           completed = $3,
           notes = $4,
           date = $5,
           time = $6,
           alarm = $7,
           assigned_user = $8
       WHERE id = $9`,
      [title, priority, completed, notes, date, time, alarm, assignedUser, id]
    );
    res.status(200).json({ message: "Task updated" });
  } catch (err) {
    console.error("PUT error:", err.message);
    res.status(500).json({ error: err.message });
  }
};

// Assign user to task
exports.assignUser = async (req, res) => {
  const { id } = req.params;
  const { username } = req.body;

  try {
    await pool.query(
      `UPDATE tasks
       SET assigned_user = $1
       WHERE id = $2`,
      [username, id]
    );
    res.status(200).json({ message: "User assigned successfully" });
  } catch (err) {
    console.error("Assign User PUT error:", err.message);
    res.status(500).json({ error: err.message });
  }
};

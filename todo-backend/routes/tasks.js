const express = require('express');
const router = express.Router();
const pool = require('../db');

// GET all tasks
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tasks ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('GET /tasks error:', err.message);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST new task
router.post('/', async (req, res) => {
  const { title, priority, completed = false, notes, date, time, alarm = false } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO tasks (title, priority, completed, notes, date, time, alarm)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [title, priority, completed, notes, date, time, alarm]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('POST /tasks error:', err.message);
    res.status(500).json({ error: 'Failed to create task' });
  }
});

// PUT update task
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { title, priority, completed, notes, date, time, alarm } = req.body;

  try {
    await pool.query(
      `UPDATE tasks
       SET title = $1,
           priority = $2,
           completed = $3,
           notes = $4,
           date = $5,
           time = $6,
           alarm = $7
       WHERE id = $8`,
      [title, priority, completed, notes, date, time, alarm, id]
    );
    res.json({ message: 'Task updated' });
  } catch (err) {
    console.error('PUT /tasks/:id error:', err.message);
    res.status(500).json({ error: 'Failed to update task' });
  }
});

// DELETE task
router.delete('/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM tasks WHERE id = $1', [req.params.id]);
    res.json({ message: 'Task deleted' });
  } catch (err) {
    console.error('DELETE /tasks/:id error:', err.message);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const pool = require('../db');

// GET all tasks
router.get('/', async (req, res) => {
  const result = await pool.query('SELECT * FROM tasks ORDER BY id ASC');
  res.json(result.rows);
});

// POST new task
router.post('/', async (req, res) => {
  const { title, priority } = req.body;
  const result = await pool.query(
    'INSERT INTO tasks (title, priority) VALUES ($1, $2) RETURNING *',
    [title, priority]
  );
  res.json(result.rows[0]);
});

// PUT update task
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { title, priority, completed } = req.body;
  await pool.query(
    'UPDATE tasks SET title=$1, priority=$2, completed=$3 WHERE id=$4',
    [title, priority, completed, id]
  );
  res.json({ message: 'Task updated' });
});

// DELETE task
router.delete('/:id', async (req, res) => {
  await pool.query('DELETE FROM tasks WHERE id=$1', [req.params.id]);
  res.json({ message: 'Task deleted' });
});

module.exports = router;

const express = require('express');
const router = express.Router();
const tasksController = require('../controllers/tasksController');

// Task Routes
router.get("/", tasksController.getAllTasks);
router.post("/", tasksController.addTask);
router.delete("/:id", tasksController.deleteTask);
router.put("/:id", tasksController.updateTask);
router.put("/:id/assign-user", tasksController.assignUser);

module.exports = router;

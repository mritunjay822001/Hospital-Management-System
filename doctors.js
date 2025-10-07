const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', async (req, res) => {
  try {
    const r = await db.simpleExecute('SELECT doctor_id, first_name, last_name, specialization FROM doctor ORDER BY doctor_id');
    res.json(r.rows);
  } catch (e) { console.error(e); res.status(500).json({error:'Server error'}) }
});

module.exports = router;

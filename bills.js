const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/patient/:id', async (req,res) => {
  try {
    const q = `SELECT b.bill_id, b.bill_dt, b.total_amt, b.paid_amt, b.status FROM bill b WHERE b.patient_id=:id ORDER BY bill_dt DESC`;
    const r = await db.simpleExecute(q, { id: Number(req.params.id) });
    res.json(r.rows);
  } catch (err) { console.error(err); res.status(500).json({ error:'Server error' }); }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const db = require('../db');
const oracledb = require('oracledb');

router.get('/', async (req, res) => {
  try {
    const q = `SELECT patient_id, first_name, last_name, dob, gender, phone FROM patient ORDER BY patient_id`;
    const result = await db.simpleExecute(q, {}, {});
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const q = `SELECT * FROM patient WHERE patient_id = :id`;
    const result = await db.simpleExecute(q, { id: Number(req.params.id) });
    if (!result.rows || result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { first_name, last_name, dob, gender, phone, email, address } = req.body;
    const q = `INSERT INTO patient(patient_id, first_name, last_name, dob, gender, phone, email, address)
               VALUES (NULL, :fn,:ln, TO_DATE(:dob,'YYYY-MM-DD'), :gender, :phone, :email, :address)`;
    await db.simpleExecute(q, { fn:first_name, ln:last_name, dob, gender, phone, email, address }, { autoCommit: true });
    res.status(201).json({ message: 'Patient created' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

router.put('/:id', async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { first_name, last_name, phone, email, address } = req.body;
    const q = `UPDATE patient SET first_name=:fn, last_name=:ln, phone=:phone, email=:email, address=:address WHERE patient_id=:id`;
    await db.simpleExecute(q, { fn:first_name, ln:last_name, phone, email, address, id }, { autoCommit: true });
    res.json({ message: 'Updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    const q = `DELETE FROM patient WHERE patient_id=:id`;
    await db.simpleExecute(q, { id: Number(req.params.id) }, { autoCommit: true });
    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

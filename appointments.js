const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/', async (req, res) => {
  try {
    const { patient_id, doctor_id, appt_dt, reason } = req.body;
    const q = `INSERT INTO appointment(appt_id, patient_id, doctor_id, appt_dt, reason)
               VALUES (NULL, :pid, :did, TO_TIMESTAMP(:adt,'YYYY-MM-DD"T"HH24:MI:SS'), :reason)`;
    await db.simpleExecute(q, { pid: patient_id, did: doctor_id, adt: appt_dt.replace('Z',''), reason }, { autoCommit: true });
    res.status(201).json({ message: 'Appointment scheduled' });
  } catch (err) {
    console.error(err); res.status(500).json({ error: 'Server error' });
  }
});

router.get('/', async (req, res) => {
  try {
    const q = `SELECT a.appt_id, a.appt_dt, a.reason, a.status,
                      p.patient_id, p.first_name || ' ' || p.last_name patient,
                      d.doctor_id, d.first_name || ' ' || d.last_name doctor
               FROM appointment a
               JOIN patient p ON a.patient_id = p.patient_id
               JOIN doctor d ON a.doctor_id = d.doctor_id
               ORDER BY a.appt_dt`;
    const r = await db.simpleExecute(q);
    res.json(r.rows);
  } catch (e) { console.error(e); res.status(500).json({ error: 'Server error' }); }
});

module.exports = router;

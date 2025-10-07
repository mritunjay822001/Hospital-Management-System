const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/admit', async (req,res) => {
  try {
    const { patient_id, room_id, admitted_by, remarks } = req.body;
    const q = `INSERT INTO admission(adm_id, patient_id, room_id, admit_dt, admitted_by, status, remarks)
               VALUES (NULL, :pid, :rid, SYSTIMESTAMP, :ab, 'ADMITTED', :remarks)`;
    await db.simpleExecute(q, { pid: patient_id, rid: room_id, ab: admitted_by, remarks }, { autoCommit: true });
    await db.simpleExecute(`UPDATE room SET is_available='N' WHERE room_id=:rid`, { rid: room_id }, { autoCommit: true });
    res.status(201).json({ message: 'Admitted' });
  } catch (err) { console.error(err); res.status(500).json({ error:'Server error' }); }
});

router.post('/discharge', async (req,res) => {
  try {
    const { adm_id } = req.body;
    const callQ = `BEGIN discharge_patient(:adm); END;`;
    await db.simpleExecute(callQ, { adm: adm_id }, { autoCommit: true });
    res.json({ message: 'Discharged and bill generated' });
  } catch (err) { console.error(err); res.status(500).json({ error:'Server error' }); }
});

module.exports = router;

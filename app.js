const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { initPool, closePool } = require('./db');
require('dotenv').config();

const patientsRouter = require('./routes/patients');
const doctorsRouter = require('./routes/doctors');
const apptsRouter = require('./routes/appointments');
const admissionsRouter = require('./routes/admissions');
const billsRouter = require('./routes/bills');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.use('/api/patients', patientsRouter);
app.use('/api/doctors', doctorsRouter);
app.use('/api/appointments', apptsRouter);
app.use('/api/admissions', admissionsRouter);
app.use('/api/bills', billsRouter);

const PORT = process.env.PORT || 4000;

initPool()
  .then(() => {
    app.listen(PORT, () => console.log(`Server started on :${PORT}`));
  })
  .catch(err => {
    console.error('Failed to init DB pool', err);
    process.exit(1);
  });

process.on('SIGINT', async () => {
  console.log('Shutting down...');
  await closePool();
  process.exit(0);
});

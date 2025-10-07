import React, { useEffect, useState } from 'react';
import { getPatients } from '../api';

export default function PatientList() {
  const [patients, setPatients] = useState([]);
  useEffect(() => { getPatients().then(setPatients).catch(console.error); }, []);
  return (
    <div>
      <h3>Patients</h3>
      <table border="1" cellPadding="6">
        <thead><tr><th>ID</th><th>Name</th><th>Phone</th></tr></thead>
        <tbody>
          {patients.map(p => (
            <tr key={p.PATIENT_ID || p.patient_id}>
              <td>{p.PATIENT_ID ?? p.patient_id}</td>
              <td>{(p.FIRST_NAME ?? p.first_name) + ' ' + (p.LAST_NAME ?? p.last_name)}</td>
              <td>{p.PHONE ?? p.phone}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

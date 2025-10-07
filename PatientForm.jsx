import React, { useState } from 'react';
import { createPatient } from '../api';

export default function PatientForm({ onCreated }) {
  const [form, setForm] = useState({ first_name:'', last_name:'', dob:'1990-01-01', gender:'Male', phone:'', email:'', address:'' });
  const submit = async (e) => {
    e.preventDefault();
    try {
      await createPatient(form);
      onCreated && onCreated();
      setForm({ first_name:'', last_name:'', dob:'1990-01-01', gender:'Male', phone:'', email:'', address:'' });
      alert('Created');
    } catch (err) { console.error(err); alert('Error'); }
  };
  return (
    <form onSubmit={submit} style={{ marginBottom: 20 }}>
      <input placeholder="First" value={form.first_name} onChange={e => setForm({...form, first_name:e.target.value})} required />
      <input placeholder="Last" value={form.last_name} onChange={e => setForm({...form, last_name:e.target.value})} />
      <input type="date" value={form.dob} onChange={e => setForm({...form, dob:e.target.value})} />
      <input placeholder="Phone" value={form.phone} onChange={e => setForm({...form, phone:e.target.value})} />
      <button>Create</button>
    </form>
  );
}

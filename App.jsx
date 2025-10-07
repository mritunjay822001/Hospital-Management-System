import React from 'react';
import PatientForm from './components/PatientForm';
import PatientList from './components/PatientList';

export default function App(){
  return (
    <div style={{ padding:20 }}>
      <h1>Hospital Management</h1>
      <PatientForm />
      <hr />
      <PatientList />
    </div>
  );
}

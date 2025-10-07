import axios from 'axios';
const API = axios.create({ baseURL: 'http://localhost:4000/api' });

export const getPatients = () => API.get('/patients').then(r => r.data);
export const createPatient = payload => API.post('/patients', payload).then(r => r.data);
export const getDoctors = () => API.get('/doctors').then(r => r.data);
export const getAppointments = () => API.get('/appointments').then(r => r.data);
export const createAppointment = payload => API.post('/appointments', payload).then(r => r.data);
export const admitPatient = payload => API.post('/admissions/admit', payload).then(r => r.data);
export const dischargePatient = payload => API.post('/admissions/discharge', payload).then(r => r.data);

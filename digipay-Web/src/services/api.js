import axios from 'axios';

const isLocal = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
const BASE_URL = isLocal ? 'http://127.0.0.1:8000' : 'https://web-production-86613.up.railway.app';

const api = axios.create({
  baseURL: BASE_URL,
  timeout: 10000, // 10 seconds timeout
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to automatically attach authorization tokens
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('digipay_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for unified error parsing
api.interceptors.response.use(
  (response) => response,
  (error) => {
    let message = 'An unexpected error occurred';
    if (error.response) {
      // Server responded with error status
      message = error.response.data?.detail || message;
    } else if (error.request) {
      // Request sent but no response received
      message = 'Cannot connect to backend server. Make sure the server is running.';
    }
    return Promise.reject(new Error(message));
  }
);

// Auth endpoints
export async function sendOTP(phoneNumber) {
  const res = await api.post('/auth/send-otp', { phone_number: phoneNumber });
  return res.data;
}

export async function verifyOTP(phoneNumber, otpCode) {
  const res = await api.post('/auth/verify-otp', {
    phone_number: phoneNumber,
    otp_code: otpCode,
  });
  // Save token for future automatic injection
  if (res.data?.access_token) {
    localStorage.setItem('digipay_token', res.data.access_token);
  }
  return res.data;
}

// User Profile update
export async function updateProfile(fullName, email, role) {
  const res = await api.post('/user/update-profile', {
    full_name: fullName,
    email: email,
    role: role
  });
  return res.data;
}

// Customer details
export async function fetchWalletAnalytics() {
  const res = await api.get('/wallet/analytics');
  return res.data;
}

// Merchant details
export async function fetchMerchantDashboard() {
  const res = await api.get('/merchant/dashboard');
  return res.data;
}

// Admin stats
export async function fetchAdminDashboard() {
  const res = await api.get('/admin/dashboard');
  return res.data;
}

export async function fetchAdminTransactions(params = {}) {
  const res = await api.get('/admin/transactions', { params });
  return res.data;
}

export async function fetchAdminMerchants() {
  const res = await api.get('/admin/merchants');
  return res.data;
}

export async function toggleMerchantStatus(id, isActive) {
  const res = await api.put(`/admin/merchants/${id}/status`, null, {
    params: { is_active: isActive }
  });
  return res.data;
}

export async function deleteMerchant(id) {
  const res = await api.delete(`/admin/merchants/${id}`);
  return res.data;
}

export async function fetchAdminAnalytics() {
  const res = await api.get('/admin/analytics');
  return res.data;
}

export default api;

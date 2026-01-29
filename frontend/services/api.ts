import axios from "axios";

// Create axios instance with base URL
const api = axios.create({
    baseURL: "/v1", // Proxy in next.config or direct URL
    headers: {
        "Content-Type": "application/json",
    },
});

// Add request interceptor to attach token
api.interceptors.request.use(
    (config) => {
        // We will store token in localStorage or similar
        if (typeof window !== "undefined") {
            const token = localStorage.getItem("token");
            if (token) {
                config.headers.Authorization = `Bearer ${token}`;
            }
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

export default api;

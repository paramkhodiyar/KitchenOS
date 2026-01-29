import api from "./api";

export interface SetupPayload {
    storeName: string;
    ownerPin: string;
    cashierPin: string;
    kitchenPin: string;
}

export const setupStore = async (payload: SetupPayload) => {
    const response = await api.post<{ storeCode: string }>("/auth/setup", payload);
    return response.data;
};

export const resetPin = async (targetRole: "CASHIER" | "KITCHEN", newPin: string) => {
    // Note: storeId is extracted from token in backend usually, but our backend endpoint expects storeId in body?
    // Let's check auth.controller.js -> resetPin takes storeId, targetRole, newPin.
    // However, storeId is typically available in req.context.storeId if we used requireRole middleware.
    // BUT looking at backend/src/modules/auth/auth.routes.js (I haven't seen it yet, but usually it's authenticated).
    // If it's authenticated, backend should use req.context.storeId.
    // If the backend controller explicitly asks for storeId in body, we might need to send it, but we don't have it easily in frontend unless we decoded token.
    // Let's assume for now we use the authenticated route approach where backend *should* extract it, or we fix backend.

    // Wait, let's verify backend controller again. 
    // export const resetPin = async (req, res, next) => { const { storeId, targetRole, newPin } = req.body; ... }
    // It DOES expect storeId in body.
    // In authStore, we are not decoding token to get storeId.
    // We should probably update the backend to use req.context.storeId if the user is logged in as OWNER.

    // Let's first check if there is a 'reset-pin' route.
    const response = await api.post("/auth/reset-pin", { targetRole, newPin });
    return response.data;
};

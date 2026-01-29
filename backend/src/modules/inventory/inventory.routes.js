import { Router } from "express";
import {
    createRawMaterial,
    getRawMaterials,
    updateRawMaterialStatus,
    updateRawMaterial,
    deleteRawMaterial
} from "./rawMaterial.controller.js";

const router = Router();

router.post("/raw-material", createRawMaterial);
router.patch("/raw-material/:id/status", updateRawMaterialStatus); // Prefer specific endpoint for status
router.put("/raw-material/:id", updateRawMaterialStatus); // Keep for backward compatibility if needed, OR replace. Let's keep existing logic but add new ones.
router.patch("/raw-material/:id", updateRawMaterial);
router.delete("/raw-material/:id", deleteRawMaterial);
router.get("/raw-material", getRawMaterials);

export default router;
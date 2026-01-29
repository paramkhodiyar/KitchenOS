import express from "express";
// import authRoutes from "./modules/auth/auth.routes.js";
import routes from "./routes.js";
import { errorHandler } from "./middleware/error.middleware.js";
import cors from "cors";
const app = express();

app.use(cors());
app.use(express.json());
// app.use("/v1/auth", authRoutes);
app.get("/", (req, res) => {
    res.send("Health Check ok!");
});


routes(app);

app.use(errorHandler);

app.listen(4040, () => {
    console.log("Server started on port 4040");
});

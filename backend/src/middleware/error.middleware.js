export const errorHandler = (err, req, res, next) => {
    const status = err.status || 500;
    const message = err.message || "Internal Server Error";

    // Log error for debugging (except 4xx errors)
    if (status >= 500) {
        console.error(err);
    }

    res.status(status).json({
        error: {
            message,
            ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
            ...(err.warnings && { warnings: err.warnings }), // Pass through warnings if any
        },
    });
};

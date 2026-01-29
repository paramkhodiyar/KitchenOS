import prisma from "../../config/prisma.js";

/**
 * Revenue report
 */
const getRevenueReport = async ({ storeId, from, to }) => {
    const where = {
        storeId,
        createdAt: {
            gte: from,
            lte: to,
        },
    };

    const income = await prisma.transaction.aggregate({
        where: { ...where, type: "INCOME" },
        _sum: { amount: true },
    });

    const expense = await prisma.transaction.aggregate({
        where: { ...where, type: "EXPENSE" },
        _sum: { amount: true },
    });

    const byAccount = await prisma.transaction.groupBy({
        by: ["accountId"],
        where: { ...where, type: "INCOME" },
        _sum: { amount: true },
    });

    return {
        totalRevenue: (income._sum.amount || 0) + (expense._sum.amount || 0), // Gross revenue if expense is negative? Usually "revenue" is income.
        // Actually, usually Total Revenue = Total Income.
        // User asked for "Total Revenue". In accounting, Revenue is just Income.
        // The previous code returned 'net' but frontend looked for 'totalRevenue' which wasn't mapped.
        // Let's map 'totalRevenue' to totalIncome.
        totalRevenue: income._sum.amount || 0,
        totalIncome: income._sum.amount || 0,
        totalExpense: expense._sum.amount || 0,
        net: (income._sum.amount || 0) - (expense._sum.amount || 0),
        byAccount,
        dailyRevenue: await getDailyRevenue(storeId, from, to),
    };
};

const getDailyRevenue = async (storeId, from, to) => {
    // Group by day. Prisma doesn't support Date_Trunc comfortably in all DBs without raw query.
    // For simplicity, fetch all and aggregate in JS (assuming not massive scale for this prototype)
    // Or use groupBy if using recent Prisma.

    // Fallback: Fetch all transactions
    const txs = await prisma.transaction.findMany({
        where: {
            storeId,
            type: "INCOME",
            createdAt: { gte: from, lte: to }
        },
        select: { createdAt: true, amount: true }
    });

    const map = {};
    txs.forEach(t => {
        const date = t.createdAt.toISOString().split('T')[0];
        map[date] = (map[date] || 0) + t.amount;
    });

    return Object.entries(map).map(([date, revenue]) => ({ date, revenue })).sort((a, b) => a.date.localeCompare(b.date));
}

/**
 * Order report
 */
const getOrderReport = async ({ storeId, from, to }) => {
    const orders = await prisma.order.findMany({
        where: {
            storeId,
            createdAt: {
                gte: from,
                lte: to,
            },
        },
        include: {
            items: true,
        },
        orderBy: { createdAt: 'asc' }
    });

    const completed = orders.filter(o => o.status === "COMPLETED");
    const cancelled = orders.filter(o => o.status === "CANCELLED");

    const totalOrders = orders.length;
    const avgOrderValue =
        completed.length === 0
            ? 0
            : completed.reduce((s, o) => s + o.total, 0) / completed.length;

    const itemMap = {};
    const dateMap = {};

    orders.forEach(order => {
        // Top Items
        order.items.forEach(item => {
            itemMap[item.productId] =
                (itemMap[item.productId] || 0) + item.quantity;
        });

        // Daily Trend
        const date = order.createdAt.toISOString().split('T')[0];
        dateMap[date] = (dateMap[date] || 0) + 1;
    });

    const recentTrends = Object.entries(dateMap)
        .map(([date, count]) => ({ date, count }))
        .sort((a, b) => a.date.localeCompare(b.date));

    return {
        totalOrders,
        completedOrders: completed.length,
        cancelledOrders: cancelled.length,
        averageOrderValue: avgOrderValue,
        topItems: itemMap,
        recentTrends,
    };
};

/**
 * Stock report
 */
const getStockReport = async ({ storeId }) => {
    const rawMaterials = await prisma.rawMaterial.findMany({
        where: { storeId },
    });

    const products = await prisma.product.findMany({
        where: { storeId, isActive: true }, // Only check active products
    });

    const items = [];

    // Add Raw Materials
    rawMaterials.forEach(rm => {
        items.push({
            id: rm.id,
            name: rm.name,
            stock: null, // No numeric stock tracking for Raw Materials
            status: rm.status,
            type: 'RAW_MATERIAL'
        });
    });

    // Add Products to items if low/out
    products.forEach(p => {
        let status = 'AVAILABLE';
        if (p.stock <= 0) status = 'OUT';
        else if (p.stock <= p.minStock) status = 'LOW';

        items.push({
            id: p.id,
            name: p.name,
            stock: p.stock,
            status: status,
            type: 'PRODUCT'
        });
    });

    // Calculate metadata
    const lowStockItems = items.filter(i => i.status === 'LOW').length;
    const outOfStockItems = items.filter(i => i.status === 'OUT').length;

    return {
        lowStockItems,
        outOfStockItems,
        totalItems: items.length,
        items
    };
};

export default {
    getRevenueReport,
    getOrderReport,
    getStockReport,
};

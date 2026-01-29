import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
    console.log("Starting seed for Chai Adda...");

    // 1. Cleanup: Delete EVERYTHING - STRICT ORDER
    console.log("Cleaning up invalid data...");

    // Child tables must be deleted before Parent tables
    await prisma.transaction.deleteMany({});
    await prisma.orderItem.deleteMany({}); // Delete OrderItems BEFORE Orders
    await prisma.order.deleteMany({});     // Now safe to delete Orders

    await prisma.overrideLog.deleteMany({});
    await prisma.stockLog.deleteMany({});

    // Now delete products and raw materials
    await prisma.product.deleteMany({});
    await prisma.rawMaterial.deleteMany({});

    // Accounts and Users
    await prisma.account.deleteMany({});
    await prisma.user.deleteMany({});

    // Finally Store
    await prisma.store.deleteMany({});

    console.log("Database cleared.");

    // 2. Create the specific store 'Chai Adda'
    // Note: User asked for store code 5096, usually KOS-XXXX. We'll stick to what user likely meant or generate KOS-5096.
    // Actually the user said "store created with 5096". Let's assume they want the code to be specifically "KOS-5096" or similar.
    // I will use "KOS-5096" to be consistent with the app pattern.
    const storeCode = "KOS-5096";
    const storeName = "Chai Adda";

    // Default PINs
    const ownerPin = "1111";
    const cashierPin = "2222";
    const kitchenPin = "3333";

    const store = await prisma.store.create({
        data: {
            name: storeName,
            storeCode: storeCode,
            ownerPinHash: await bcrypt.hash(ownerPin, 10),
            cashierPinHash: await bcrypt.hash(cashierPin, 10),
            kitchenPinHash: await bcrypt.hash(kitchenPin, 10),
            isInitialized: true,
        },
    });

    console.log(`Created Store: ${store.name} (${store.storeCode})`);

    // 3. Create Accounts
    const cashAccount = await prisma.account.create({
        data: {
            storeId: store.id,
            name: "Cash Register",
            type: "CASH",
            balance: 0,
        }
    });

    const upiAccount = await prisma.account.create({
        data: {
            storeId: store.id,
            name: "Main UPI",
            type: "UPI",
            balance: 0,
        }
    });

    // 4. Products (Menu) - Relevant to Chai Adda context
    const productsData = [
        { name: "Masala Chai", price: 20, stock: 100, minStock: 20 },
        { name: "Adrak Chai", price: 25, stock: 100, minStock: 20 },
        { name: "Elaichi Chai", price: 25, stock: 90, minStock: 15 },
        { name: "Cutting Chai", price: 15, stock: 150, minStock: 30 },
        { name: "Bun Maska", price: 40, stock: 40, minStock: 10 },
        { name: "Bun Omelette", price: 60, stock: 30, minStock: 5 },
        { name: "Vada Pav", price: 30, stock: 50, minStock: 10 },
        { name: "Samosa", price: 20, stock: 60, minStock: 10 },
        { name: "Samosa Pav", price: 25, stock: 50, minStock: 10 },
        { name: "Maggie", price: 50, stock: 80, minStock: 15 },
        { name: "Cheese Maggie", price: 70, stock: 70, minStock: 15 },
        { name: "Veg Cheese Sandwich", price: 80, stock: 25, minStock: 5 },
        { name: "Chicken Sandwich", price: 100, stock: 20, minStock: 5 },
        { name: "Cold Coffee", price: 80, stock: 40, minStock: 10 },
        { name: "Lemon Tea", price: 30, stock: 60, minStock: 10 },
        { name: "Bread Pakora", price: 30, stock: 30, minStock: 5 },
        { name: "Poha", price: 40, stock: 30, minStock: 5 },
        { name: "Upma", price: 40, stock: 25, minStock: 5 },
        { name: "Mineral Water", price: 20, stock: 100, minStock: 20 },
        { name: "Bournvita", price: 60, stock: 40, minStock: 10 },
    ];

    const products = [];
    for (const p of productsData) {
        const product = await prisma.product.create({
            data: { ...p, storeId: store.id },
        });
        products.push(product);
    }
    console.log(`Created ${products.length} products`);

    // 5. Raw Materials - Some OUT/LOW as requested
    const rawMaterialsData = [
        { name: "Tea Powder", status: "AVAILABLE" },
        { name: "Fresh Milk", status: "AVAILABLE" },
        { name: "Sugar", status: "AVAILABLE" },
        { name: "Ginger", status: "LOW" }, // LOW
        { name: "Cardamom", status: "AVAILABLE" },
        { name: "Vada Pav Buns", status: "AVAILABLE" },
        { name: "Bread Loaves", status: "AVAILABLE" },
        { name: "Potatoes", status: "AVAILABLE" },
        { name: "Onions", status: "AVAILABLE" },
        { name: "Butter", status: "AVAILABLE" },
        { name: "Cheese Slices", status: "OUT" }, // OUT
        { name: "Eggs", status: "AVAILABLE" },
        { name: "Maggie Packs", status: "AVAILABLE" },
        { name: "Disposable Cups", status: "LOW" }, // LOW
        { name: "Tissues", status: "AVAILABLE" },
    ];

    for (const r of rawMaterialsData) {
        await prisma.rawMaterial.create({
            data: { ...r, storeId: store.id },
        });
    }
    console.log(`Created ${rawMaterialsData.length} raw materials`);

    // 6. Generate Sales History (Transactions & Orders) for past 7 days
    const today = new Date();
    for (let i = 6; i >= 0; i--) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);

        // Random number of orders per day (15 to 40 for a busy chai adda)
        const orderCount = Math.floor(Math.random() * 26) + 15;

        for (let j = 0; j < orderCount; j++) {
            // Random items in order
            const itemSize = Math.floor(Math.random() * 3) + 1; // 1-3 items typically
            const orderItems = [];
            let totalAmount = 0;

            for (let k = 0; k < itemSize; k++) {
                const product = products[Math.floor(Math.random() * products.length)];
                const qty = Math.floor(Math.random() * 3) + 1; // 1-3 quantity
                totalAmount += product.price * qty;
                orderItems.push({
                    productId: product.id,
                    quantity: qty,
                    price: product.price,
                });
            }

            // Create Order
            const orderTime = new Date(date);
            // Chai Adda timings: 7 AM to 10 PM
            orderTime.setHours(7 + Math.floor(Math.random() * 15), Math.floor(Math.random() * 60));

            const isCash = Math.random() > 0.3; // 70% Cash at Chai Adda

            const order = await prisma.order.create({
                data: {
                    storeId: store.id,
                    total: totalAmount,
                    status: "COMPLETED",
                    createdAt: orderTime,
                    items: {
                        create: orderItems,
                    },
                },
            });

            // Create Transaction (Income)
            await prisma.transaction.create({
                data: {
                    storeId: store.id,
                    accountId: isCash ? cashAccount.id : upiAccount.id,
                    amount: totalAmount,
                    type: "INCOME",
                    note: `Order #${order.orderNumber || order.id}`,
                    createdAt: orderTime,
                    orderId: order.id,
                },
            });
        }
        console.log(`Simulated day ${i} days ago: ${orderCount} orders`);
    }

    console.log("\n=== SEED COMPLETE ===");
    console.log("Store: Chai Adda");
    console.log("Code: " + storeCode);
    console.log("PINs: 1111 (Owner), 2222 (Cashier), 3333 (Kitchen)");
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });

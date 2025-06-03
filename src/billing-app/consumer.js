var amqp = require('amqplib');
require('dotenv').config();

const Pool = require('pg').Pool
const pool = new Pool({
    user: process.env.ORDERS_DB_USER,
    host: process.env.ORDERS_DB_HOST,
    database: process.env.ORDERS_DB_NAME,
    password: process.env.ORDERS_DB_PASSWORD,
    port: process.env.ORDERS_DB_PORT,
})

const QUEUE = process.env.BILLING_QUEUE;

async function startConsumer() {
    const connection = await amqp.connect('amqp://${process.env.RABBITMQ_HOST}');
    const channel = await connection.createChannel();
    await channel.assertQueue(QUEUE, { durable: true });

    console.log('[*] Waiting for messages in %s.', QUEUE);
    channel.consume(QUEUE, msg => {
        if (msg !== null) {
            const billingData = JSON.parse(msg.content.toString());

        
            pool.query(
        `INSERT INTO ${process.env.ORDERS_TABLE} (user_id,number_of_items, total_amount) VALUES ($1, $2, $3) RETURNING *`,
                [billingData.user_id, billingData.number_of_items, billingData.total_amount],  
        (error, results) => {
             if (error) {
                    console.error('Database insertion error:', error.message);
                    // Optionally: do not ack the message to retry later
                    return;
                }
            // response.status(201).json(results.rows[0])
            console.log('[x] Billing data inserted:', billingData);
            channel.ack(msg); // Acknowledge message after successful insert
        }
    )

        }

        
    }, { noAck: false });
}

startConsumer();

// amqp.connect('amqp://localhost', function(error0, connection) {
//     if (error0) throw error0;

//     connection.createChannel(function(error1, channel) {
//         if (error1) throw error1;

//         var queue = 'hello';

//         channel.assertQueue(queue, {
//             durable: true
//         });

//         console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", queue);

//         channel.consume(queue, function(msg) {
//             console.log(" [x] Received %s", msg.content.toString());
//         }, {
//             noAck: true
//         });
//     });
// });

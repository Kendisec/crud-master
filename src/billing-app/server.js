const express = require('express');
const amqp = require('amqplib');

const app = express();
const QUEUE = 'billing_queue';
let channel;

app.use(express.json()); // ✅ Make sure JSON body is parsed

async function connectRabbitMQ() {
    const connection = await amqp.connect('amqp://localhost');
    channel = await connection.createChannel();
    await channel.assertQueue(QUEUE, { durable: true });
    console.log(`Connected to RabbitMQ and listening on queue: ${QUEUE}`);
}

app.post('/api/billing', async (req, res) => {
    const billingData = req.body; // ✅ Should now contain JSON

    if (!billingData || !billingData.title || !billingData.description) {
        return res.status(400).send({ error: 'Missing title or description' });
    }

    try {
        const msgBuffer = Buffer.from(JSON.stringify(billingData));
        channel.sendToQueue(QUEUE, msgBuffer, { persistent: true });
        res.status(202).send({ message: 'Billing data queued' });
    } catch (err) {
        console.error('Error sending to queue:', err);
        res.status(500).send({ error: 'Queueing failed' });
    }
});

connectRabbitMQ().then(() => {
    app.listen(3000, () => {
        console.log('API Server running on http://localhost:3000');
    });
}).catch(err => {
    console.error('Failed to connect to RabbitMQ', err);
});

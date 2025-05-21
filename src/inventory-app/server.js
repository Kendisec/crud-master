const express = require('express');
const app = express();
const db = require('./queries.js');
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.get('/api/movies', (req, res) =>{
    db.getMovies(req, res);
})

app.listen(3000, () => {
    console.log("listenning on 192.168.56.12")
});
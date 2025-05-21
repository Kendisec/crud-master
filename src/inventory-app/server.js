const express = require('express');
const app = express();
const db = require('.queries');
app.route('/', (req, res) => {
    
});

app.listen(3000, () => {
    console.log("listenning")
});
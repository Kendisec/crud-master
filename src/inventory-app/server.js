const express = require('express');
const app = express();
const db = require('./queries.js');
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.get('/api/movies', (req, res) =>{
    db.getMovies(req, res);
})

app.get('/api/movies/:id', (req, res) =>{
    db.getMoviebyId(req, res);
}); 

app.delete('/api/movies/:id', (req, res) =>{
    db.deleteMovie(req, res);
});

app.put('/api/movies/:id', (req, res) =>{
    db.updateMovie(req, res);
});

app.listen(3000, () => {
    console.log("listenning on 192.168.56.12")
});